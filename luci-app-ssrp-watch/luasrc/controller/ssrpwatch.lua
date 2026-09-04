-- File and module names carry no hyphen on purpose: the dispatcher require()s
-- luci.controller.<name>, and the package name ssrp-watch would not survive
-- that. Only the identifiers change; the package, the UCI config and the
-- binary are all still ssrp-watch.
module("luci.controller.ssrpwatch", package.seeall)

function index()
	-- No config file means the package is not installed, and the menu entry
	-- must not appear. This is what lets luci-app-ssr-plus stay untouched:
	-- the tab shows up because this package is here, not because ssr-plus
	-- was taught to look for it.
	if not nixio.fs.access("/etc/config/ssrp-watch") then
		return
	end

	-- Order 40 sits between Access Control (30) and Advanced Settings (50)
	-- in luci-app-ssr-plus's own menu.
	entry({"admin", "services", "shadowsocksr", "watch"},
		cbi("ssrpwatch"), _("Tunnel Watchdog"), 40).leaf = true

	-- Siblings rather than children: the page above is a leaf, so it cannot
	-- carry sub-entries. Both are title-less and therefore hidden from the
	-- menu.
	entry({"admin", "services", "shadowsocksr", "watch_status"}, call("act_status")).leaf = true
	entry({"admin", "services", "shadowsocksr", "watch_test"}, call("act_test")).leaf = true
	entry({"admin", "services", "shadowsocksr", "watch_clear"}, post("act_clear")).leaf = true
end

local HISTORY = "/etc/ssrp-watch.history"
local INCIDENT_LOG = "/tmp/ssrp-incident.log"
local LOCK    = "/tmp/.ssrp-watch.pid"

-- The daemon maintains the pid file itself and clears it on exit, so it is
-- the authoritative liveness source. /proc/<pid> guards against a stale one
-- left by a kill -9.
local function daemon_pid()
	local pid = nixio.fs.readfile(LOCK)
	if not pid then return nil end
	pid = pid:match("^%s*(%d+)")
	if pid and nixio.fs.access("/proc/" .. pid) then
		return tonumber(pid)
	end
	return nil
end

function act_status()
	local sys = require "luci.sys"
	local e = {}

	e.pid = daemon_pid()
	e.running = (e.pid ~= nil)
	e.enabled = (luci.model.uci.cursor():get("ssrp-watch", "config", "enabled") == "1")

	-- Last ten state changes, newest first.
	e.history = {}
	local fd = io.open(HISTORY, "r")
	if fd then
		local all = {}
		for line in fd:lines() do all[#all + 1] = line end
		fd:close()
		for i = #all, math.max(1, #all - 9), -1 do
			e.history[#e.history + 1] = all[i]
		end
		e.total = #all
	else
		e.total = 0
	end

	-- Incidents in the last seven days, counted off the date prefix rather
	-- than by parsing timestamps: the file is written by this package and
	-- the format is fixed.
	local cutoff = os.date("%Y-%m-%d", os.time() - 7 * 86400)
	e.recent = 0
	fd = io.open(HISTORY, "r")
	if fd then
		for line in fd:lines() do
			local d = line:match("^(%d%d%d%d%-%d%d%-%d%d)")
			if d and d >= cutoff and line:find("INCIDENT", 1, true) then
				e.recent = e.recent + 1
			end
		end
		fd:close()
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

-- Empties the record. Truncates rather than unlinks so the daemon's own
-- appends keep landing in the same inode -- it holds no handle open, but a
-- deleted file would also drop the mode and owner the package installed with.
-- The verbose snapshots in /tmp go too: they are the long form of the very
-- entries being discarded, and keeping them would leave the page claiming an
-- empty history while the log still carries the detail.
function act_clear()
	local e = { ret = 0 }

	local fd = io.open(HISTORY, "w")
	if fd then
		fd:close()
	else
		e.ret = 1
		e.error = "history"
	end

	-- Absent is the normal state after a reboot, so only a failed truncate
	-- of a file that does exist counts against us.
	if nixio.fs.access(INCIDENT_LOG) then
		local lg = io.open(INCIDENT_LOG, "w")
		if lg then
			lg:close()
		else
			e.ret = 1
			e.error = (e.error and (e.error .. ",log")) or "log"
		end
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

-- Runs the self-test capture and returns it verbatim. Slow on purpose: it
-- pings three targets ten times each and samples the WAN counters over two
-- seconds, because those numbers are the point. Around forty seconds.
function act_test()
	local out = luci.sys.exec("/usr/bin/ssrp-watch -t 2>&1")
	luci.http.prepare_content("text/plain; charset=utf-8")
	luci.http.write(out or "")
end
