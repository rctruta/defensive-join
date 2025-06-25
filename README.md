# A Configurable Framework for SQL Performance Benchmarking at Scale

## Code for Substack Article Series on Database Performance

### Project Overview

This repository hosts the code and configurations for a series of Substack articles focused on SQL database performance benchmarking. Our goal is to provide reproducible benchmarks for various SQL operations and database configurations, offering insights into query optimization and database design, particularly for **PostgreSQL** environments orchestrated via **Docker Compose**.

This project enables readers to replicate the benchmark results discussed in the articles and adapt the setup for their own performance analysis needs.

### Technologies Used

* **PostgreSQL**: The relational database management system being benchmarked.
* **Docker**: Containerization platform for isolated database environments.
* **Docker Compose**: Tool for defining and running multi-container Docker applications (orchestrating the database and benchmark tools).
* **SQL**: The primary language for defining schemas, loading data, and executing benchmark queries.
* **Bash**: For automating the data generation and benchmark execution workflows via shell scripts.

### Repository Structure

```
/sql-benchmark-framework/
├── README.md                      \# This file.
├── .gitignore             # Standard Git ignore file (temp files, IDE configs, etc.).
├── benchmark.conf         # The central configuration file.
├── docker-compose.yml     # The definition of your isolated test environment.
├── run_all_benchmarks.sh  # The single entry point for the user.
│
├── scripts/                       \# Shell scripts for automating workflows.
│   ├── 1_generate_and_setup_db.sh
│   ├── run_join_suite.sh
│   ├── run_groupby_suite.sh
│   └── run_single_test.sh
│   └── ... (other helpers)
│
├── sql/                           # Contains all SQL scripts used by the benchmarks.
│   ├── setup_template.sql
│   ├── cleanup_orphans_template.sql # Cleans up the orphan records.
│   └── queries/
│       ├── left_join_benchmark.sql
│       └── ... 
├── data/                          # Automatically generated CSV datasets.
│   ├── customers.csv
│   └── orders.csv
│
├── results/                        # Directory for storing benchmark output and reports.
│   ├── .gitkeep           # An empty file to ensure the directory is in git.
│   └── benchmark_summary.csv # A sample of the final output, not the huge one.
│   └── join/                        # Contains results from '2_run_benchmarks.sh'
│   │   ├── left_outer_join_dirty_results.txt
│   │   ├── inner_join_dirty_results.txt
│   │   └── inner_join_clean_results.txt
│   └── groupby/                     # Contains results from '3_run_groupby_benchmark.sh'
│       ├── groupby_anti_pattern_results.txt
│       └── groupby_recommended\_results.txt
│
└── visualizations/
    ├── create_visualizations.py # The Python script for analysis.
    └── (This is where the generated .html plots will go)

```

### Getting Started: Running the Benchmarks

This section guides you through setting up your environment and running the SQL performance benchmarks.

**Prerequisites:**

* **Docker Desktop** (or Docker Engine and Docker Compose CLI plugin) installed on your system.

**Workflow Overview:**

The benchmarking process is divided into three main sequential steps, orchestrated by convenient shell scripts:
1.  **Generate Synthetic Data:** Create the necessary `customers.csv` and `orders.csv` datasets.
2.  **Run Join Benchmarks:** Execute performance tests comparing different JOIN strategies.
3.  **Run Group By Benchmarks:** Perform performance tests on different GROUP BY approaches.

**Steps:**

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/yourusername/your-repo-name.git](https://github.com/yourusername/your-repo-name.git)
    cd your-repo-name
    ```
    *(Replace `yourusername` and `your-repo-name` with your actual GitHub username and repository name.)*

2.  **Generate Synthetic Data:**
    * This script will start a temporary PostgreSQL container, generate synthetic `customers` and `orders` data, export it to `customers.csv` and `orders.csv` in the `data/` directory of your repository, and then shut down the temporary container.
    * **Note:** This step may take several minutes.
    ```bash
    bash scripts/1_generate_data.sh
    ```
    * Once complete, you should see `customers.csv` and `orders.csv` in your `data/` directory.

3.  **Run Join Benchmarks:**
    * This script executes benchmarks comparing a "Defensive" LEFT JOIN against a "Trusting" INNER JOIN.
    * Results will be saved to `results/join/`.
    ```bash
    bash scripts/2_run_benchmarks.sh
    ```

4.  **Run Group By Benchmarks:**
    * This script executes benchmarks for different GROUP BY strategies.
    * Results will be saved to `results/groupby/`.
    ```bash
    bash scripts/3_run_groupby_benchmark.sh
    ```

**Database Details (from `docker-compose.yml`):**
* **Service Name:** `postgres_db`
* **Image:** `postgres`
* **Default User:** `postgres`
* **Password:** `mysecretpassword`
* **Port:** `5432:5432`
* **Volume Mount:** The current repository directory is mounted into `/scripts` inside the container, allowing scripts and SQL files to be accessed.

**Important Notes:**
* Ensure Docker Desktop is running before executing any scripts.
* Each benchmark script will automatically bring up and tear down the necessary Docker containers for isolation.
* For advanced troubleshooting or manual interaction, you can use `docker compose up -d postgres_db` to start the database and then `docker compose exec postgres_db psql -U postgres` to connect to it. Remember `docker compose down` to stop and remove containers.

