local nt = require "luci.sys".net
local fs=require"nixio.fs"

m=Map("serverchan",translate("hint："),
translate("If you don’t understand the meaning of these options，Please do not modify the options"))

s = m:section(TypedSection, "serverchan", "advanced settings")
s.anonymous = true
s.addremove = false

a=s:option(Value,"up_timeout",translate('Device online detection timed out（s）'))
a.default = "2"
a.optional=false
a.datatype="uinteger"

a=s:option(Value,"down_timeout",translate('Device offline detection timed out（s）'))
a.default = "20"
a.optional=false
a.datatype="uinteger"

a=s:option(Value,"timeout_retry_count",translate('Number of offline detections'))
a.default = "2"
a.optional=false
a.datatype="uinteger"
a.description = translate("If there is no secondary routing equipment，Good signal strength，Can reduce the above value<br/>Due to night wifi Hibernation is more metaphysical，Encountered frequent device push disconnects，Please adjust the parameters yourself<br/>..╮(╯_╰）╭..")

a=s:option(Value,"thread_num",translate('Maximum number of concurrent processes'))
a.default = "3"
a.datatype="uinteger"

a=s:option(Value, "soc_code", "Custom temperature read command")
a.rmempty = true 
a:value("",translate("default"))
a:value("pve",translate("PVE virtual machine"))
a.description = translate("If you need to use special symbols for custom commands，Such as quotation marks、$、!Wait，You need to escape it yourself，And view after saving /etc/config/serverchan document soc_code Whether the setting items are saved correctly<br/>can use eval `echo $(uci get serverchan.serverchan.soc_code)` Command to view command output and error information<br/>The execution result must be a pure number（Can take decimals），For temperature comparison")

a=s:option(Value,"server_host",translate("Host address"))
a.rmempty=true
a.default="10.0.0.2"
a.description = translate("")
a:depends({soc_code="pve"})

a=s:option(Value,"server_port",translate("Host SSH port"))
a.rmempty=true
a.default="22"
a.description = translate("SSH The port defaults to 22，If customized，Please fill in custom SSH port<br/>Please confirm that the key has been set to log in，Otherwise it will cause errors such as the script cannot run！<br/>PVE Install sensors Command to Baidu<br/>Key login example（Modify the address and port number by yourself）：<br/>opkg update #update list<br/>opkg install openssh-client openssh-keygen #InstallopensshClient<br/>ssh-keygen -t rsa # Generate key file（Set your own password and other information）<br/>ssh root@10.0.0.2 -p 22 \"tee -a ~/.ssh/id_rsa.pub\" < ~/.ssh/id_rsa.pub # Send the public key to PVE<br/>ssh root@10.0.0.2 -p 22 \"cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys\" # Write public key to PVE<br/>ssh -i /root/.ssh/id_rsa root@10.0.0.2 -p 22 sensors # Connect with private key PVE Test temperature command")
a:depends({soc_code="pve"})

a=s:option(Button,"soc",translate("Test temperature command"))
a.inputtitle = translate("Output information")
a.write = function()
	luci.sys.call("/usr/bin/serverchan/serverchan soc")
	luci.http.redirect(luci.dispatcher.build_url("admin","services","serverchan","advanced"))
end

if nixio.fs.access("/tmp/serverchan/soc_tmp") then
e=s:option(TextValue,"soc_tmp")
e.rows=2
e.readonly=true
e.cfgvalue = function()
	return luci.sys.exec("cat /tmp/serverchan/soc_tmp && rm -f /tmp/serverchan/soc_tmp")
end
end

a=s:option(Flag,"err_enable",translate("Unattended mission"))
a.default=0
a.rmempty=true
a.description = translate("Please confirm that the script can run normally，Otherwise it may cause frequent restarts and other errors！")

a=s:option(Flag,"err_sheep_enable",translate("Redial only during do-not-disturb hours"))
a.default=0
a.rmempty=true
a.description = translate("Avoid redialing during the day ddns The domain name is waiting to be resolved，This function does not affect the disconnection detection<br/>Due to running flow problems at night，The function may be unstable")
a:depends({err_enable="1"})

a= s:option(DynamicList, "err_device_aliases", translate("Watchlist"))
a.rmempty = true 
a.description = translate("It will only be executed when the devices in the list are not online<br/>One hour after the do-not-disturb period，Pay attention to the low flow of the device for five minutes（restrain100kb/m）Will be considered offline")
nt.mac_hints(function(mac, name) a :value(mac, "%s (%s)" %{ mac, name }) end)
a:depends({err_enable="1"})

a=s:option(ListValue,"network_err_event",translate("When the network is disconnected"))
a.default=""
a:depends({err_enable="1"})
a:value("",translate("No action"))
a:value("1",translate("Restart the router"))
a:value("2",translate("Redial"))
a:value("3",translate("Modify related settings，Try to repair the network automatically"))
a.description = translate("Options 1 Options 2 Will not modify settings，And try at most 2 Second-rate。<br/>Options 3 The settings will be backed up in /usr/bin/serverchan/configbak content，And restore after failure。<br/>【！！Compatibility cannot be guaranteed！！】Not familiar with system settings，Don't use it if it won't save the brick")

a=s:option(ListValue,"system_time_event",translate("Restart regularly"))
a.default=""
a:depends({err_enable="1"})
a:value("",translate("No action"))
a:value("1",translate("Restart the router"))
a:value("2",translate("Redial"))

a= s:option(Value, "autoreboot_time", "System running time is greater than")
a.rmempty = true 
a.default = "24"
a.datatype="uinteger"
a:depends({system_time_event="1"})
a.description = translate("Unit is hour")

a=s:option(Value, "network_restart_time", "Network online time is greater than")
a.rmempty = true 
a.default = "24"
a.datatype="uinteger"
a:depends({system_time_event="2"})
a.description = translate("Unit is hour")

a=s:option(Flag,"public_ip_event",translate("Redial try to get public network ip"))
a.default=0
a.rmempty=true
a:depends({err_enable="1"})
a.description = translate("Will not be pushed when redialing ip Change notice，And will cause your domain name to fail to update in time ip address<br/>Please confirm that you can get the public network by redialing ip，Otherwise, this will not only be futile, but will also cause frequent disconnections<br/>If you wait for the big intranet, don’t struggle！！")

a= s:option(Value, "public_ip_retry_count", "Maximum number of retries in the day")
a.rmempty = true 
a.default = "10"
a.datatype="uinteger"
a:depends({public_ip_event="1"})

return m
