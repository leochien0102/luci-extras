# luci-app-ssrp-watch

Watches whether the ssr-plus tunnel actually carries traffic, and captures a
forensic snapshot at the moment it stops.

## Why it exists

Outages at one site kept resolving themselves before anything could be
measured. Every useful number -- packet loss on the uplink versus past it,
conntrack state to the node, who on the LAN was generating the connections --
is only observable *during* the fault. This runs continuously so that the
snapshot is taken then, rather than reconstructed afterwards.

## What it probes

A DNS query for a random label under a domain that is routed through the
tunnel. A cached answer cannot satisfy it, so any reply at all -- records or
NXDOMAIN -- proves the query travelled dnsmasq -> dns2tcp -> tunnel ->
upstream and came back.

Liveness checks were tried first and are useless here: during the incidents
the client process was alive and opening dozens of connections per second.
Its ClientHello simply never reached the far end.

## What it records

Two tiers:

- `/tmp/ssrp-incident.log` -- the full snapshot, in RAM, rotated at a size cap.
- `/etc/ssrp-watch.history` -- one line per state change, on flash, listed in
  `/lib/upgrade/keep.d` so it survives sysupgrade. This is what answers "has
  this been happening?" after the reboot that so often follows an outage.

## Where it appears

Under *Services -> ShadowSocksR Plus+ -> Tunnel Watchdog*. The tab is
registered by this package's own controller, so it appears when the package is
installed and not otherwise -- luci-app-ssr-plus needs no change to
accommodate it.

## Notes

The script carries a block of comments recording seven busybox and ssr-plus
traps that produced wrong readings during development -- the proxy process not
being named after its product, the node being configured by hostname while
conntrack only shows addresses, ICMP to an Azure node always reporting total
loss, and so on. Those comments are the most valuable part of the file. Do not
strip them.
