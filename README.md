# prometheus-apt-paketstatus
Shell Script to get Apt Updates to Promtheus via node_exporter / file.

This Script will produce `apt.prom` under a given Path so that the node_exporter can read this and publish tha values.


Exported Values:
- apt_upgrades_pending
- apt_autoremove_pending
- apt_securityupgrades_pending
- node_reboot_required


# Configuration

## node_exporter: 

- Create a Directory with read permissions for `node_exporter`
- if you use systemd, add to `ExecStart` the following switch: `--collector.textfile.directory <path to obove created Directory>`

## Script:

- Move the Script `apt-metrics.sh` to `/usr/share/apt-metrics` 
- `chmod +x /usr/share/apt-metrics` to make it executable


# Apt Configuration

Add the following Script to `/etc/apt/apt.conf.d/60prometheus-metrics` and replace `/var/lib/node_exporter/textfile_collector` with your previously created path:

```
# /etc/apt/apt.conf.d/60prometheus-metrics

APT::Update::Post-Invoke-Success {
  "/usr/share/apt-metrics | sponge /var/lib/node_exporter/textfile_collector/apt.prom || true"
};

DPkg::Post-Invoke {
  "/usr/share/apt-metrics | sponge /var/lib/node_exporter/textfile_collector/apt.prom || true"
};
```

