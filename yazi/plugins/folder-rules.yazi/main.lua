local function setup()
	ps.sub("cd", function()
		local cwd = cx.active.current.cwd
		if cwd:ends_with("Downloads") or cwd:ends_with("Media/Screenshots") or cwd:ends_with("/home/phoenix/Documents/PixivUtil2/pixiv") then
			ya.manager_emit("sort", { "mtime", reverse = true, dir_first = false })
		else
			ya.manager_emit("sort", { "alphabetical", reverse = false, dir_first = true })
		end
	end)
end

return { setup = setup }
