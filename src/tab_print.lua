table_print={}
local function printTableFile(item_str,savetofile)
	if savetofile ~= nil then
		savetofile:write(item_str.."\r\n");
	else
		print(item_str);
	end
end
---
-- @function: 打印table的内容，递归
-- @param: tbl 要打印的table
-- @param: level 递归的层数，默认不用传值进来
-- @param: filteDefault 是否过滤打印构造函数，默认为是
-- @return: return
function table_print.PrintTable( tbl ,savetofile, level, filteDefault)
	local msg = ""
	
	filteDefault = filteDefault or true --默认过滤关键字（DeleteMe, _class_type）
	level = level or 1
	
	local indent_str = ""
	for i = 1, level do
		indent_str = indent_str.."  "
	end
	printTableFile(indent_str .. "{",savetofile)
	
	local key_test ={}
	for i in pairs(tbl) do
		table.insert(key_test,i)   --提取tbl中的键值插入到key_test表中
	end
	table.sort(key_test)
	for _,v in pairs(key_test) do
		local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(v), tostring(tbl[v]))
		printTableFile(item_str,savetofile)
	end
	
	for k,v in pairs(tbl) do
		if filteDefault then
			if k ~= "_class_type" and k ~= "DeleteMe" then
				local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
				--printTableFile(item_str,savetofile)
				if type(v) == "table" then
					table_print.PrintTable(v, savetofile,level + 1)
				end
			end
		else
			local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
			--printTableFile(item_str,savetofile)
			if type(v) == "table" then
				table_print.PrintTable(v,savetofile,level + 1)
			end
		end
	end
	
	printTableFile(indent_str .. "}",savetofile)
end

return table_print;



--[[
-- 文件名为 module.lua
-- 定义一个名为 module 的模块
module = {}
 
-- 定义一个常量
module.constant = "这是一个常量"
 
-- 定义一个函数
function module.func1()
    io.write("这是一个公有函数！\n")
end
 
local function func2()
    print("这是一个私有函数！")
end
 
function module.func3()
    func2()
end
 
return module
--]]