#!/bin/bash
# Master Orchestrator for the Benchmark Framework
# Usage: ./run_all_benchmarks.sh [joins|groupby|all]

set -e # Exit immediately if a command exits with a non-zero status.

# --- Load Configuration ---
if [ -f benchmark.conf ]; then
    echo "[INFO] Loading configuration from benchmark.conf..."
    source benchmark.conf
else
    echo "[ERROR] Configuration file benchmark.conf not found." >&2
    exit 1
fi

# --- Argument Handling ---
SUITE_TO_RUN=$1
if [[ "$SUITE_TO_RUN" != "joins" && "$SUITE_TO_RUN" != "groupby" && "$SUITE_TO_RUN" != "all" ]]; then
    echo "Usage: $0 [joins|groupby|all]" >&2
    exit 1
fi

# --- Initial Setup (Runs ONCE) ---
initial_setup() {
    echo "[INFO] Performing initial setup..."
    rm -f "$SUMMARY_CSV"
    mkdir -p results/join results/groupby
    echo "\"Test Name\",\"Timestamp\",\"Data Size\",\"Query Execution Duration\"" > "$SUMMARY_CSV"
}

# --- Main Logic ---
initial_setup

# Convert space-separated strings from config into proper shell arrays
CUSTOMER_COUNTS_ARR=($CUSTOMER_COUNTS)
ORDER_COUNTS_ARR=($ORDER_COUNTS)
ORPHAN_PERCENTAGES_ARR=($ORPHAN_PERCENTAGES)

# Safety net: This command will run if the script is interrupted (e.g., by Ctrl+C)
trap 'echo -e "\n[INFO] Script interrupted. Forcibly shutting down containers..."; docker compose down --volumes &> /dev/null' EXIT

for NUM_CUSTOMERS in "${CUSTOMER_COUNTS_ARR[@]}"; do
    # Exporting allows sub-scripts to see this variable
    export NUM_CUSTOMERS
    for NUM_ORDERS in "${ORDER_COUNTS_ARR[@]}"; do
        for ORPHAN_PERCENTAGE in "${ORPHAN_PERCENTAGES_ARR[@]}"; do
            echo -e "\n======================================================="
            echo "[INFO] Preparing environment for: C=${NUM_CUSTOMERS}, O=${NUM_ORDERS}, P=${ORPHAN_PERCENTAGE}%"
            echo "======================================================="

            bash scripts/1_generate_and_setup_db.sh "$NUM_CUSTOMERS" "$NUM_ORDERS" "$ORPHAN_PERCENTAGE"

            if [[ "$SUITE_TO_RUN" == "all" || "$SUITE_TO_RUN" == "joins" ]]; then
                echo -e "\n--- Running JOIN Benchmark Suite ---"
                bash scripts/run_join_suite_WITH_FK.sh
            fi

            if [[ "$SUITE_TO_RUN" == "all" || "$SUITE_TO_RUN" == "groupby" ]]; then
                echo -e "\n--- Running GROUP BY Benchmark Suite ---"
                bash scripts/run_groupby_suite.sh
            fi
            
            echo "[INFO] Shutting down environment for this parameter set..."
            docker compose down --volumes
        done
    done
done

trap - EXIT # Disable the trap for a clean exit
echo -e "\n======================================================="
echo "[SUCCESS] Master Orchestration Complete!"
echo "======================================================="