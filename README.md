# crossover-trial-renew

A tool which resets the crossover trial in order to achieve using crossover for free, practically acting as a way to crack crossover.  
Built upon santaklouse's CrossOver.sh.

## Manual Reset

Run the following command in terminal:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/av1155/crossover-reset/refs/heads/main/reset-crossover.sh)"
```

## Automated Reset (Cron Job)

To automatically reset the trial every 13 days, set up a cron job:

1. Open crontab: `crontab -e`
2. Add the following line (runs daily at 2 AM):
   ```
   0 2 * * * /bin/bash -c "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/av1155/crossover-reset/refs/heads/main/crossover-reset-scheduler.sh)"
   ```

The scheduler will automatically track the last reset and only execute when 13 days have passed.
