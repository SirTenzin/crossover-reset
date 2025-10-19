# crossover-trial-renew

A tool which resets the crossover trial in order to achieve using crossover for free, practically acting as a way to crack crossover.  
Built upon santaklouse's CrossOver.sh.

## Manual Reset

Run the following command in terminal:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/av1155/crossover-reset/refs/heads/main/reset-crossover.sh)"
```

## Automated Reset (Cron Job)

To automatically reset the trial every 13 days, set up a cron job with `crossover-reset-scheduler.sh`:

1. Clone this repository
2. Make the scheduler executable: `chmod +x crossover-reset-scheduler.sh`
3. Add to crontab: `crontab -e`
4. Add the following line (runs daily at 2 AM):
   ```
   0 2 * * * /path/to/crossover-reset-scheduler.sh
   ```
