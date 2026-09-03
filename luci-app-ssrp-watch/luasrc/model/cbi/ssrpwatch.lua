local m, s, o

m = Map("ssrp-watch", translate("Tunnel Watchdog"),
	translate("Probes whether the tunnel actually carries traffic, and captures a forensic snapshot at the moment it stops. The probe is a random-label DNS query through the tunnel: a cached answer cannot satisfy it, so a reply proves the whole path worked."))

s = m:section(SimpleSection)
s.template = "ssrpwatch/status"

s = m:section(NamedSection, "config", "ssrp-watch", translate("Settings"))
s.addremove = false
s.anonymous = true

o = s:option(Flag, "enabled", translate("Enable"))
o.description = translate("Runs as a procd service, restarted automatically if it dies.")
o.rmempty = false
o.default = "0"

o = s:option(Value, "interval", translate("Check interval (s)"))
o.datatype = "and(uinteger,min(5))"
o.default = "15"
o.rmempty = false

o = s:option(Value, "fail_threshold", translate("Failures before an incident"))
o.description = translate("Consecutive failed probes required before a snapshot is taken. Two at fifteen seconds means a fault has to persist for half a minute, which keeps a single dropped query out of the record.")
o.datatype = "and(uinteger,min(1))"
o.default = "2"
o.rmempty = false

o = s:option(Value, "recapture", translate("Re-snapshot interval (s)"))
o.description = translate("While still down, take another snapshot this often.")
o.datatype = "and(uinteger,min(60))"
o.default = "300"
o.rmempty = false

o = s:option(Value, "log_max", translate("Incident log size cap (bytes)"))
o.description = translate("The verbose log lives in /tmp, which is RAM. It rotates once above this size.")
o.datatype = "and(uinteger,min(65536))"
o.default = "524288"
o.rmempty = false

o = s:option(Value, "probe_domain", translate("Probe domain"))
o.description = translate("Must be a domain that is routed through the tunnel, i.e. one in gfw_list.conf. A domestic domain would resolve fine during a total outage and the probe would never fire.")
o.datatype = "host"
o.default = "google.com"
o.rmempty = false

o = s:option(Value, "probe_cn", translate("Domestic ICMP target"))
o.description = translate("Pinged unproxied. Together with the overseas target this is what separates a broken uplink from a broken international route. Avoid 114.114.114.114: something on the path answers for it in 0 ms, so it measures nothing beyond the gateway.")
o.datatype = "ipaddr"
o.default = "223.5.5.5"
o.rmempty = false

o = s:option(Value, "probe_intl", translate("Overseas ICMP target"))
o.description = translate("Pinged unproxied. Loss here with a clean domestic target puts the fault on the international egress, which nothing on this router can fix.")
o.datatype = "ipaddr"
o.default = "1.1.1.1"
o.rmempty = false

return m
