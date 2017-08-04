map_paser={}

function find_lib_name(stack,lib_list)
	if stack==nil or stack <0  then
		print("invalid stack"..stack)
	end
	if lib_list==nil then
		print("lib_list is nil ")
	end
	
	for i,v in ipairs(lib_list) do
		--print('lib_list ',i,lib)
		if v.start_addr < stack and stack < v.end_addr then
			return v;
		end
	end
	return nil;
end

--str = "/www/var/tmp/temp.lua" will get "temp.lua"
function subString(str, k)
	ts=string.reverse(str)
	_,i = string.find(ts, k)
	e = string.len(ts)
	s = e - i + 2
	return string.sub(str, s, e) 
end

--[[
linux /proc/进程/maps 的文件格式：
start_addr-end_addr r-xp 00000000 103:0f 955      lib_name
73dcc000-73ded000 r-xp 00000000 103:0f 955       /system/lib/libformat_open.so
--]]
function map_paser.parse(input_file,libinfo_list)
	local fileHandle = assert(io.open(input_file, "r"), "error ["..input_file.."] file is not exsists");
	local exe_seg = "r-xp";
	local lib_prefix = " /";
	local i=1;
	for l in fileHandle:lines() do
		--only select the line content "r-xp"
		--findkey(l,"pid","&");
		aa,bb = string.find(l,exe_seg)
		if bb ~=nil and aa >17 then
			libinfo_list[i]={}
			libinfo_list[i].org_item=l;
			libinfo_list[i].start_addr=tonumber(string.sub(l,0,8),16);
			libinfo_list[i].end_addr=tonumber(string.sub(l,10,17),16);
			libinfo_list[i].lib_with_path='unknow'
			cc,dd = string.find(l,lib_prefix)
			if  dd ~=nil then
				libinfo_list[i].lib_with_path=string.sub(l,dd);	
			end
			i=i+1;
		end
	end
	fileHandle:close();	
end

 
function map_paser.get_stack_detail_list(stack_list,libinfo_list)
	local stack_detail_list={};
	local j=1;
	for _,v in ipairs(stack_list) do
			--print('stack ',v)				
			stack_detail_list[j]={}
			stack_detail_list[j].stack=v;
			stack_detail_list[j].stack_hex_str=string.format("0x%x",v);
			local lib = find_lib_name(v,libinfo_list);
			stack_detail_list[j].lib=lib.lib_with_path;		
			stack_detail_list[j].lib_name=subString(lib.lib_with_path, '/');	
			stack_detail_list[j].offset=v-lib.start_addr;	
			stack_detail_list[j].offset_hex_str=string.format("0x%x",stack_detail_list[j].offset);
			--table_print.PrintTable(stack_detail_list[j],nil)			
			j=j+1;
	end
	return stack_detail_list;
end

return map_paser