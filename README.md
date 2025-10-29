# crossover-reset

A tool which resets the crossover start day.  
Built upon santaklouse's CrossOver.sh and Nygosaki's implementation.

## Manual Reset

Run the following command in terminal:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/SirTenzin/crossover-reset/refs/heads/main/reset-crossover.sh)"
```

## Automated Reset (Cron Job)

To automatically reset Crossover every 13 days, set up a cron job with `crossover-reset-scheduler.sh`:

1. Clone this repository
    > Cloning the repo is necessary because the scheduler writes a temporary file to track the last time it was run.
1. Make the scheduler executable: `chmod +x crossover-reset-scheduler.sh`
1. Add to crontab: `crontab -e`
1. Add the following line (runs daily at 5 AM):

    ```cron
    0 5 * * * mkdir -p /path/to/crossover-reset/logs && /usr/bin/env bash /path/to/crossover-reset/crossover-reset-scheduler.sh > /path/to/crossover-reset/logs/reset-crossover.log 2>&1
    ```

    > Replace each occurrence of /path/to/ with your actual absolute path to your cloned repo.
