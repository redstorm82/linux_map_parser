--dofile("D:\\working\\openSource\\lua\\linux_map_parser\\src\\num_convert.lua") 
--dofile("D:\\working\\openSource\\lua\\linux_map_parser\\src\\tab_print.lua") 
--dofile("D:\\working\\openSource\\lua\\linux_map_parser\\src\\map_parser.lua") 
--dofile("D:\\working\\openSource\\lua\\linux_map_parser\\src\\mm_parser.lua")
require("num_convert") 
require("tab_print")
require("map_parser")
require("mm_parser")

--default
input_map="D:\\working\\openSource\\lua\\linux_map_parser\\tests\\tester1.map"
input_mm=input_map..".mm"
--[[
@stack_list  input
@output_file_name  input
@return 0 success, -1 fail
--]]
function save_stack_list_file(stack_list_array,libinfo_list,output_file_name)	
	if stack_list_array==nil or libinfo_list==nil or output_file_name==nil then
		print("stack_list_array or libinfo_list or output_file_name is nil ")
		return -1;
	end
	
	local detail_list={};
	
	local addr2line ="arm-linux-androideabi-addr2line "
	local save_fd = io.open(output_file_name, "w");		
	
	for i,v in ipairs(stack_list_array) do
		--print('stack_list ',v)		
		--lib_name offset_hex_str
		stack_list = v.stack;
		detail_list = map_paser.get_stack_detail_list(stack_list,libinfo_list);
		--table_print.PrintTable(detail_list,nil)		
	
		save_fd:write("\n=================================\n");
		save_fd:write("org call stack  :\n");
		save_fd:write(v.org_item);
		--[[
		for i,v in ipairs(stack_list) do			
			str = string.format("0x%08x ",v);
			save_fd:write(str);
		end
		--]]
		save_fd:write("\n=================================\n");
		save_fd:write("\nparsed call stack:\n");
		for i,v in ipairs(detail_list) do
			--print('detail_list ',i,v)		
			--lib_name offset_hex_str
			str = string.format("%s %s %s\n",v.offset_hex_str,v.lib_name,v.lib);
			save_fd:write(str);
		end
		
		save_fd:write("\n=================================\n");
		save_fd:write("\nstack commands:\n");
		for i,v in ipairs(detail_list) do
			--print('detail_list ',i,v)		
			--lib_name offset_hex_str
			str = string.format("%s -e %s -f %s \n",addr2line,v.lib_name,v.offset_hex_str);
			save_fd:write(str);
		end		
	end --end for i,v in ipairs(stack_list) 
	save_fd:close();
	return 0;
end


if arg and #arg>0 then
	input_map=arg[1];
	input_mm=input_map..".mm"
	if #arg >= 2 then
		input_mm=arg[2];
	end
	
	print("arg table count "..#arg)
	table_print.PrintTable(arg)
	for i,v in ipairs(arg) do
		print('arg ',i,v)
	end
else	
	print("==============================================")	
	print("usage: lua main.lua map_file_name mm_file_name")	
	print("==============================================")		
end

print("map file :  ", input_map)
print("mm file :  ", input_mm)

local libinfo_list ={};
map_paser.parse(input_map,libinfo_list)
--table_print.PrintTable(libinfo_list,nil,1,nil);

local stack_list={};
mm_parser.parse(input_mm,stack_list)
--table_print.PrintTable(stack_list);

local output_file_name=input_map..".parsed"
local res = save_stack_list_file(stack_list,libinfo_list,output_file_name) 
if res ==0 then
print(output_file_name," file created")
else
print(output_file_name," file create fail")
end


