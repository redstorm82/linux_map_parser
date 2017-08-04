mm_parser={}

--字符串分割函数
--传入字符串和分隔符，返回分割后的table
function string.split(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end


--[[
.mm文件格式1：
size     4217, dup   14, 0x7540401a, 0x754042e8, 0x76edacfe, 0x74752aa2, 0x74784250, 0x7478460e, 0x74784818, 0x73dd754c, 0x73dd8948, 0x7478468c, 0x747a3a1a, 0x7478468c, 0x74784828, 0x74785ab4, 0x747e5192, 0x73dfe4fc, 0x73dff07c, 0x754a3ed8, 0x754a8882, 0x754a92ba, 0x754a09e2, 0x762f06b4, 0x762f6afe, 0x76e6558e, 0x76eda228, 0x76eda3c0
--]]
function parse_mm_type1(input_fd,stack_list)
	local exe_seg = " 0x";
	local i=1;
	input_fd:seek("set")
	for l in input_fd:lines() do
		--only select the line content " 0x"
		aa,bb = string.find(l,exe_seg)
		if bb ~=nil then
			stack_list[i]={}
			stack_list[i].org_item=l;
			stack=string.upper(string.sub(l,aa+1));			
			stack_list[i].stack_str=string.split(stack,", ");	
			stack_list[i].stack={};
			local j=1;
			for _,v in ipairs(stack_list[i].stack_str) do
				--print('stack ',v)				
				stack_list[i].stack[j]=ConvertStr2Dec(string.sub(v,2),16);		
				j=j+1;
			end
			i=i+1;
		end
	end
	if i > 1 then
		return 0
	else
		return -1
	end
end

--[[
.mm文件格式2：
z 1  sz   524288  num    1  bt 2c81601a 2b0ebcae 2b13991a 2beea78e 2beea82e 2bed0e92 2bed287e 2bed28be 2bed2968 2bed315a 2bed1a76 2bed1b54 2bed1bba 2bed1d7e 2bed9902 2bed7690 2bed5ccc 2bed66a2 2bed6718 2bed5ccc 2bed66a2 2bed6718 2bed5ccc 2bed66a2 2bed6718 2bed5ccc 2bed66a2 2bed6718 2bed5ccc 2bed66a2 2bed6718 2bed5ccc
--]]

--[[
@input_fd  input
@stack_list  input&output
@return 0 success, -1 fail
--]]
function parse_mm_type2(input_fd,stack_list)
	local exe_seg = " bt ";
	local i=1;
	input_fd:seek("set")
	for l in input_fd:lines() do
		--only select the line content " bt "
		aa,bb = string.find(l,exe_seg)
		if bb ~=nil then
			stack_list[i]={}
			stack_list[i].org_item=l;
			--must call string.upper because  ConvertStr2Dec function need upper input
			stack=string.upper(string.sub(l,bb+1));			
			stack_list[i].stack_str=string.split(stack," ");	
			stack_list[i].stack={}
			local j=1;
			for _,v in ipairs(stack_list[i].stack_str) do
				--print('stack ',v)				
				stack_list[i].stack[j]=ConvertStr2Dec(v,16);					
				j=j+1;
			end
			i=i+1;
		end
	end
	if i > 1 then
		return 0
	else
		return -1
	end
end

--[[
@input_file  input
@stack_list  input&output
@return 0 success, -1 fail
--]]
function mm_parser.parse(input_file,stack_list)
	if input_file==nil or stack_list==nil or stack_list=='' then
		print("input_file or stack_list is nil ")
		return -1;
	end
	
	local fileHandle = assert(io.open(input_file, "r"), "error ["..input_file.."] file is not exsists");
	res =  parse_mm_type1(fileHandle,stack_list) ;
	if res ==-1 then
		res = parse_mm_type2(fileHandle,stack_list) ;
	end
	
	fileHandle:close();	
	
	return res;
end

return mm_parser