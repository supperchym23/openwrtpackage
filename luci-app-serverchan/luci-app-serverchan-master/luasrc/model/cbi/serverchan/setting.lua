  
local nt = require "luci.sys".net
local fs=require"nixio.fs"
local e=luci.model.uci.cursor()
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local ifaces = sys.net:devices()

m=Map("serverchan",translate("ServerChan"),
translate("「ServerSauce」，English name「ServerChan」，It is a tool to push alarm information and logs from the server to WeChat。<br /><br />If you encounter problems in use，Please submit here：")
.. [[<a href="https://github.com/supperchym23/luci-app-serverchan" target="_blank">]]
.. translate("github project address")
.. [[</a>]]
)

m:section(SimpleSection).template  = "serverchan/serverchan_status"

s=m:section(NamedSection,"serverchan","serverchan",translate(""))
s:tab("basic", translate("basic settings"))
s:tab("content", translate("Push content"))
s:tab("crontab", translate("Timed push"))
s:tab("disturb", translate("Do not disturb"))
s.addremove = false
s.anonymous = true

--基本设置
a=s:taboption("basic", Flag,"serverchan_enable",translate("Enable"))
a.rmempty = true

a = s:taboption("basic", MultiValue, "lite_enable", translate("Reduced mode"))
a:value("device", translate("Streamline the current device list"))
a:value("nowtime", translate("Simplify the current time"))
a:value("content", translate("Only push title"))
a.widget = "checkbox"
a.default = nil
a.optional = true

a=s:taboption("basic", ListValue,"jsonpath",translate("Push mode"))
a.default="/usr/bin/serverchan/api/serverchan.json"
a.rmempty = true
a:value("/usr/bin/serverchan/api/serverchan.json",translate("WeChat ServerSauce"))
a:value("/usr/bin/serverchan/api/qywx_mpnews.json",translate("Enterprise WeChat Graphic message"))
a:value("/usr/bin/serverchan/api/qywx_markdown.json",translate("Enterprise WeChat markdownVersion（Official account is not supported）"))
a:value("/usr/bin/serverchan/api/wxpusher.json",translate("WeChat wxpusher"))
a:value("/usr/bin/serverchan/api/pushplus.json",translate("WeChat pushplus"))
a:value("/usr/bin/serverchan/api/telegram.json",translate("Telegram"))
a:value("/usr/bin/serverchan/api/diy.json",translate("Custom push"))

a=s:taboption("basic", Value,"sckey",translate('WeChat push/Old and new'), translate("").."ServerSauce sendkey <a href='https://sct.ftqq.com/' target='_blank'>click here</a><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/serverchan.json")

a=s:taboption("basic", Value,"corpid",translate('enterpriseID(corpid)'),translate("").."Get instructions <a href='https://work.weixin.qq.com/api/doc/10013' target='_blank'>click here</a>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_mpnews.json")
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_markdown.json")
a=s:taboption("basic", Value,"userid",translate('account number(userid)'))
a.rmempty = true
a.description = translate("Please fill in for mass posting to application @all ")
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_mpnews.json")
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_markdown.json")
a=s:taboption("basic", Value,"agentid",translate('applicationid(agentid)'))
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_mpnews.json")
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_markdown.json")
a=s:taboption("basic", Value,"corpsecret",translate('Application key(Secret)'))
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_mpnews.json")
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_markdown.json")
a=s:taboption("basic", Value,"mediapath",translate('Image thumbnail file path'))
a.rmempty = true
a.default = "/usr/bin/serverchan/api/logo.jpg"
a:depends("jsonpath","/usr/bin/serverchan/api/qywx_mpnews.json")
a.description = translate("Only supports 2MB Within JPG,PNG Format <br> 900*383 or 2.35:1 Better ")

a=s:taboption("basic",Value,"wxpusher_apptoken",translate('appToken'),translate("").."Obtain appToken <a href='https://wxpusher.zjiecode.com/docs/#/?id=%e5%bf%ab%e9%80%9f%e6%8e%a5%e5%85%a5' target='_blank'>click here</a><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/wxpusher.json")
a=s:taboption("basic", Value,"wxpusher_uids",translate('uids'))
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/wxpusher.json")
a=s:taboption("basic",Value,"wxpusher_topicIds",translate('topicIds(Mass mailing)'),translate("").."Interface Description <a href='https://wxpusher.zjiecode.com/docs/#/?id=%e5%8f%91%e9%80%81%e6%b6%88%e6%81%af-1'target='_blank'>click here</a><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/wxpusher.json")

a=s:taboption("basic",Value,"pushplus_token",translate('pushplus_token'),translate("").."Obtainpushplus_token <a href='http://www.pushplus.plus/' target='_blank'>click here</a><br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/pushplus.json")

a=s:taboption("basic", Value, "tg_token", translate("TG_token"),translate("").."Get bot<a href='https://t.me/BotFather' target='_blank'>click here</a><br>Send a message with the created bot，Open conversation<br>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/telegram.json")
a=s:taboption("basic", Value,"chat_id",translate('TG_chatid'),translate("").."Obtain chat_id <a href='https://t.me/getuserIDbot' target='_blank'>click here</a>")
a.rmempty = true
a:depends("jsonpath","/usr/bin/serverchan/api/telegram.json")

a=s:taboption("basic", TextValue, "diy_json", translate("Custom push"))
a.optional = false
a.rows = 28
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/serverchan/api/diy.json")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/serverchan/api/diy.json", value:gsub("\r\n", "\n"))
end
a:depends("jsonpath","/usr/bin/serverchan/api/diy.json")

a=s:taboption("basic", Button,"__add",translate("Send test"))
a.inputtitle=translate("send")
a.inputstyle = "apply"
function a.write(self, section)
	luci.sys.call("cbi.apply")
	luci.sys.call("/usr/bin/serverchan/serverchan test &")
end

a=s:taboption("basic", Value,"device_name",translate('Name of this device'))
a.rmempty = true
a.description = translate("The name of the device will be identified in the title of the push message，Used to distinguish the source device of the push information")

a=s:taboption("basic", Value,"sleeptime",translate('Detection interval（s）'))
a.rmempty = true
a.optional = false
a.default = "60"
a.datatype="and(uinteger,min(10))"
a.description = translate("The shorter the time, the more timely the response，But will take up more system resources")

a=s:taboption("basic", ListValue,"oui_data",translate("MACEquipment Information Database"))
a.rmempty = true
a.default=""
a:value("",translate("closure"))
a:value("1",translate("Simplified version"))
a:value("2",translate("full version"))
a:value("3",translate("Network query"))
a.description = translate("Need to download 4.36m Raw data，Full version contract after processing 1.2M，Simplified version 250kb <br/>If there is no ladder，Do not use web query")

a=s:taboption("basic", Flag,"oui_dir",translate("Download to memory"))
a.rmempty = true
a:depends("oui_data","1")
a:depends("oui_data","2")
a.description = translate("Too lazy to do automatic updates，Download to memory，Restart will re-download <br/>If there is no ladder，Let's go down to the fuselage")

a=s:taboption("basic", Flag,"reset_regularly",translate("Reset flow data every day at zero"))
a.rmempty = true

a=s:taboption("basic", Flag,"debuglevel",translate("Open log"))
a.rmempty = true

a= s:taboption("basic", DynamicList, "device_aliases", translate("Device alias"))
a.rmempty = true
a.description = translate("<br/> Please enter the device MAC And device alias，use“-”Separate，like：<br/> XX:XX:XX:XX:XX:XX-MAC")

--设备状态
a=s:taboption("content", ListValue,"serverchan_ipv4",translate("ipv4 Change notice"))
a.rmempty = true
a.default=""
a:value("",translate("closure"))
a:value("1",translate("Get through the interface"))
a:value("2",translate("Get via URL"))

a = s:taboption("content", ListValue, "ipv4_interface", translate("Interface name"))
a.rmempty = true
a:depends({serverchan_ipv4="1"})
for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
a.description = translate("<br/>General choice wan interface，Please choose your own multi-dial environment")

a=s:taboption("content", TextValue, "ipv4_list", translate("ipv4 api list"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/serverchan/api/ipv4.list")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/serverchan/api/ipv4.list", value:gsub("\r\n", "\n"))
end
a.description = translate("<br/>Due to server stability、Frequent connections and other reasons cause the acquisition to fail<br/>If the interface can be obtained normally IP，Not recommended<br/>Random address access from the above list")
a:depends({serverchan_ipv4="2"})

a=s:taboption("content", ListValue,"serverchan_ipv6",translate("ipv6 Change notice"))
a.rmempty = true
a.default="disable"
a:value("0",translate("closure"))
a:value("1",translate("Get through the interface"))
a:value("2",translate("Get via URL"))

a = s:taboption("content", ListValue, "ipv6_interface", translate("Interface name"))
a.rmempty = true
a:depends({serverchan_ipv6="1"})
for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
a.description = translate("<br/>General choice wan interface，Please choose your own multi-dial environment")

a=s:taboption("content", TextValue, "ipv6_list", translate("ipv6 api list"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/serverchan/api/ipv6.list")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/serverchan/api/ipv6.list", value:gsub("\r\n", "\n"))
end
a.description = translate("<br/>Due to server stability、Frequent connections and other reasons cause the acquisition to fail<br/>If the interface can be obtained normally IP，Not recommended<br/>Random address access from the above list")
a:depends({serverchan_ipv6="2"})


a=s:taboption("content", Flag,"serverchan_up",translate("Device online notification"))
a.default=1
a.rmempty = true

a=s:taboption("content", Flag,"serverchan_down",translate("Device offline notification"))
a.default=1
a.rmempty = true

a=s:taboption("content", Flag,"cpuload_enable",translate("CPU Load alarm"))
a.default=1
a.rmempty = true

a= s:taboption("content", Value, "cpuload", "Load alarm threshold")
a.default = 2
a.rmempty = true
a:depends({cpuload_enable="1"})

a=s:taboption("content", Flag,"temperature_enable",translate("CPU Temperature alarm"))
a.default=1
a.rmempty = true
a.description = translate("Please confirm that the device can get the temperature，To modify the command，Please move to advanced settings")

a= s:taboption("content", Value, "temperature", "Temperature alarm threshold")
a.rmempty = true
a.default = "80"
a.datatype="and(uinteger,min(1))"
a:depends({temperature_enable="1"})
a.description = translate("<br/>The device alarm will only be pushed when the set value is exceeded for five consecutive minutes<br/>And I won’t be reminded for the second time within an hour")

a=s:taboption("content", Flag,"client_usage",translate("Abnormal flow of equipment"))
a.default=0
a.rmempty = true

a= s:taboption("content", Value, "client_usage_max", "Flow limit per minute")
a.default = "10M"
a.rmempty = true
a:depends({client_usage="1"})
a.description = translate("Device abnormal flow alarm（byte），You can append K or M")

a=s:taboption("content", Flag,"client_usage_disturb",translate("Abnormal traffic do not disturb"))
a.default=1
a.rmempty = true
a:depends({client_usage="1"})

a = s:taboption("content", DynamicList, "client_usage_whitelist", translate("Abnormal traffic watch list"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({client_usage_disturb="1"})
a.description = translate("Please enter the device MAC")

a=s:taboption("content", Flag,"web_logged",translate("web Login reminder"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"ssh_logged",translate("ssh Login reminder"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"web_login_failed",translate("web Wrong attempt reminder"))
a.default=0
a.rmempty = true

a=s:taboption("content", Flag,"ssh_login_failed",translate("ssh Wrong attempt reminder"))
a.default=0
a.rmempty = true

a= s:taboption("content", Value, "login_max_num", "Number of wrong attempts")
a.default = "3"
a.datatype="and(uinteger,min(1))"
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("Push reminder after exceeding the number of times")

a=s:taboption("content", Flag,"web_login_black",translate("Automatic blackout"))
a.default=0
a.rmempty = true
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("The number of times will not be reset until restart，Please add whitelist first")

a= s:taboption("content", Value, "ip_black_timeout", "Blackout time (seconds)")
a.default = "86400"
a.datatype="and(uinteger,min(0))"
a:depends("web_login_black","1")
a.description = translate("0 For permanent blackout，Use with caution<br>If unfortunately misuse，Please change the device IP Enter LUCI Interface clearing rules")

a=s:taboption("content", DynamicList, "ip_white_list", translate("whitelist IP List"))
a.datatype = "ipaddr"
a.rmempty = true
luci.ip.neighbors({family = 4}, function(entry)
	if entry.reachable then
		a:value(entry.dest:string())
	end
end)
a:depends("web_logged","1")
a:depends("ssh_logged","1")
a:depends("web_login_failed","1")
a:depends("ssh_login_failed","1")
a.description = translate("Ignore whitelist login reminders and block black operations，Does not support mask bit representation temporarily")

a=s:taboption("content", TextValue, "ip_black_list", translate("IP Blacklist"))
a.optional = false
a.rows = 8
a.wrap = "soft"
a.cfgvalue = function(self, section)
    return fs.readfile("/usr/bin/serverchan/api/ip_blacklist")
end
a.write = function(self, section, value)
    fs.writefile("/usr/bin/serverchan/api/ip_blacklist", value:gsub("\r\n", "\n"))
end
a:depends("web_login_black","1")

--定时推送
a=s:taboption("crontab", ListValue,"crontab",translate("Scheduled task settings"))
a.rmempty = true
a.default=""
a:value("",translate("closure"))
a:value("1",translate("Timed sending"))
a:value("2",translate("Interval sending"))

a=s:taboption("crontab", ListValue,"regular_time",translate("Send time"))
a.rmempty = true
for t=0,23 do
a:value(t,translate("every day"..t.."point"))
end	
a.default=8	
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"regular_time_2",translate("Send time"))
a.rmempty = true
a:value("",translate("closure"))
for t=0,23 do
a:value(t,translate("every day"..t.."point"))
end	
a.default="closure"
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"regular_time_3",translate("Send time"))
a.rmempty = true

a:value("",translate("closure"))
for t=0,23 do
a:value(t,translate("every day"..t.."point"))
end	
a.default="closure"
a.datatype=uinteger
a:depends("crontab","1")

a=s:taboption("crontab", ListValue,"interval_time",translate("Sending interval"))
a.rmempty = true
for t=1,23 do
a:value(t,translate(t.."Hour"))
end
a.default=6
a.datatype=uinteger
a:depends("crontab","2")
a.description = translate("<br/>from 00:00 Start，Every * Sent every hour")

a= s:taboption("crontab", Value, "send_title", translate("WeChat push title"))
a:depends("crontab","1")
a:depends("crontab","2")
a.placeholder = "OpenWrt By supperchym Routing status："
a.description = translate("<br/>Use of special symbols may cause transmission failure")

a=s:taboption("crontab", Flag,"router_status",translate("System operation"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"router_temp",translate("Equipment temperature"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")
 
a=s:taboption("crontab", Flag,"router_wan",translate("WAN information"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2")

a=s:taboption("crontab", Flag,"client_list",translate("Client List"))
a.default=1
a:depends("crontab","1")
a:depends("crontab","2") 

e=s:taboption("crontab", Button,"_add",translate("Send manually"))
e.inputtitle=translate("send")
e:depends("crontab","1")
e:depends("crontab","2")
e.inputstyle = "apply"
function e.write(self, section)
luci.sys.call("cbi.apply")
        luci.sys.call("/usr/bin/serverchan/serverchan send &")
end

--免打扰
a=s:taboption("disturb", ListValue,"serverchan_sheep",translate("Do not disturb time setting"),translate("Within the specified hourly time period，Pause push messages<br/>Do not disturb time，Scheduled push will also be blocked。"))
a.rmempty = true

a:value("",translate("closure"))
a:value("1",translate("Mode one：Script hangs"))
a:value("2",translate("Mode two：Silent mode"))
a.description = translate("Mode one stop all detection，Including unattended。")
a=s:taboption("disturb", ListValue,"starttime",translate("Do not disturb start time"))
a.rmempty = true

for t=0,23 do
a:value(t,translate("every day"..t.."point"))
end
a.default=0
a.datatype=uinteger
a:depends({serverchan_sheep="1"})
a:depends({serverchan_sheep="2"})
a=s:taboption("disturb", ListValue,"endtime",translate("Do not disturb end time"))
a.rmempty = true

for t=0,23 do
a:value(t,translate("every day"..t.."point"))
end
a.default=8
a.datatype=uinteger
a:depends({serverchan_sheep="1"})
a:depends({serverchan_sheep="2"})

a=s:taboption("disturb", ListValue,"macmechanism",translate("MAC filtering"))
a:value("",translate("disable"))
a:value("allow",translate("Ignore devices in the list"))
a:value("block",translate("Notify only devices in the list"))
a:value("interface",translate("Notify this interface device only"))
a.rmempty = true

a = s:taboption("disturb", DynamicList, "serverchan_whitelist", translate("Ignore list"))
nt.mac_hints(function(mac, name) a :value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism="allow"})
a.description = translate("AA:AA:AA:AA:AA:AA\\|BB:BB:BB:BB:BB:B You can combine multiple MAC Treat as the same user<br/>No more push after any device is online，Push only when all devices are offline，Avoid double wifi Frequent push")

a = s:taboption("disturb", DynamicList, "serverchan_blacklist", translate("Watchlist"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism="block"})
a.description = translate("AA:AA:AA:AA:AA:AA\\|BB:BB:BB:BB:BB:B You can combine multiple MAC Treat as the same user<br/>No more push after any device is online，Push only when all devices are offline，Avoid double wifi Frequent push")

a = s:taboption("disturb", ListValue, "serverchan_interface", translate("Interface name"))
a:depends({macmechanism="interface"})
a.rmempty = true

for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		a:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end

a=s:taboption("disturb", ListValue,"macmechanism2",translate("MAC filter 2"))
a:value("",translate("disable"))
a:value("MAC_online",translate("Do not disturb when any device in the list is online"))
a:value("MAC_offline",translate("Do not disturb after all devices in the list are offline"))
a.rmempty = true

a = s:taboption("disturb", DynamicList, "MAC_online_list", translate("Online Do Not Disturb List"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism2="MAC_online"})

a = s:taboption("disturb", DynamicList, "MAC_offline_list", translate("Any offline do not disturb list"))
nt.mac_hints(function(mac, name) a:value(mac, "%s (%s)" %{ mac, name }) end)
a.rmempty = true
a:depends({macmechanism2="MAC_offline"})

return m
