local function indent(level)
	return string.rep("      ", level);
end

local function printTableBody(table, level)
	local maxDepth = 5;
	
	-- Beyond table print depth?
	if (level > maxDepth) then
		print(indent(level) .. '...');
		return;
	end

	-- For every key/value pair...
	for key, value in pairs(table) do
	
		-- Construct key string
		local keyString = tostring(key) .. ": ";
		
		-- Table?
		if (type(value) == "table") then
			
			-- Empty?
			if (next(value) == nil) then
				-- Print empty table on same line
				print(indent(level) .. keyString .. "{}");
				
			else
				-- Print table recursively
				print(indent(level) .. keyString .. "{");
				printTableBody(value, level+1);
				print(indent(level) .. "}");
			end
		else
			
			-- Print key and value
			print(indent(level) .. keyString .. tostring(value));
		end
	end
end

function printTable(table)
	if (type(table) ~= 'table') then
		print(table);
		return;
	end
	print(tostring(table) .. ': {');
	printTableBody(table, 1);
	print('}')
end