-- Copyright (c) 2007-2008 Aleksey Cheusov <vle@gmx.net>
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
-- LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
-- OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
-- WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module ("alt_getopt", package.seeall)

local function convert_short2long (opts)
   local i = 1
   local len = #opts
   local ret = {}

   while i <= len do
      if opts:sub (i+1, i+1) == ":" then
	 ret [opts:sub (i, i)] = 1
      else
	 ret [opts:sub (i, i)] = 0
      end

      i = i + 1
   end

   return ret
end

local function err_unknown_opt (opt)
   error ("Unknown option `-" ..
		    (#opt > 1 and "-" or "") .. opt .. "'\n", 0)
end

local function canonize (options, opt)
   if not options [opt] then
      err_unknown_opt (opt)
   end

   while type (options [opt]) == "string" do
      opt = options [opt]

      if not options [opt] then
	 err_unknown_opt (opt)
      end
   end

   return opt
end

function get_ordered_opts (arg, sh_opts, long_opts)
   local i      = 1
   local count  = 1
   local opts   = {}
   local optarg = {}

   local options = convert_short2long (sh_opts)
   for k,v in pairs (long_opts) do
      options [k] = v
   end

   while i <= #arg do
      local a = arg [i]

      if a == "--" then
	 i = i + 1
	 break

      elseif a == "-" then
	 break

      elseif a:sub (1, 2) == "--" then
	 local pos = a:find ("=", 1, true)

	 if pos then
	    local opt = a:sub (3, pos-1)

	    opt = canonize (options, opt)

	    if options [opt] == 0 then
	       error ("Bad usage of option `" .. a .. "'\n", 0)
	    end

	    optarg [count] = a:sub (pos+1)
	    opts [count] = opt
	 else
	    local opt = a:sub (3)

	    opt = canonize (options, opt)

	    if options [opt] == 0 then
	       opts [count] = opt
	    else
	       if i == #arg then
		  error ("Missed value for option `" .. a .. "'\n", 0)
	       end

	       optarg [count] = arg [i+1]
	       opts [count] = opt
	       i = i + 1
	    end
	 end
	 count = count + 1

      elseif a:sub (1, 1) == "-" then
	 local j
	 for j=2,a:len () do
	    local opt = canonize (options, a:sub (j, j))

	    if options [opt] == 0 then
	       opts [count] = opt
	    elseif a:len () == 2 then
	       if i == #arg then
		  error ("Missed value for option `" .. a .. "'\n", 0)
	       end

	       optarg [count] = arg [i+1]
	       opts [count] = opt
	       i = i + 1
	       count = count + 1
	       break
	    elseif j == 2 then
	       optarg [count] = a:sub (3)
	       opts [count] = opt
	       count = count + 1
	       break
	    else
	       error ("Bad usage of option `-" .. opt .. "'\n", 0)
	    end
	    count = count + 1
	 end
      else
	 break
      end

      i = i + 1
   end

   return opts,i,optarg
end

function get_opts (arg, sh_opts, long_opts)
   local opts
   local i
   local optarg
   local ret = {}

   opts,optind,optarg = alt_getopt.get_ordered_opts (arg, sh_opts, long_opts)
   for i,v in ipairs (opts) do
      if optarg [i] then
	 ret [v] = optarg [i]
      else
	 ret [v] = 1
      end
   end

   return ret,optind
end
