# Based on Dave Koelle's Alphanum algorithm
# Rik Hemsley, 2007
# See also http://rikkus.info/arch/sensible_sort.rb
#
# Modified by Tom Wardrop to support leading zero's.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#

module Enumerable
	def sensible_sort
		sort { |a, b| grouped_compare(a, b) }
	end

	def sensible_sort!
		sort! { |a, b| grouped_compare(a, b) }
	end
	
	private

	def grouped_compare(a, b)
		loop {
			a_chunk, a = extract_alpha_or_number_group(a)
			b_chunk, b = extract_alpha_or_number_group(b)
      chunks = [a_chunk, b_chunk]
      max_length = chunks.map { |v| v.length }.max
      chunks.map! { |v| v.rjust(max_length, "\0") }
			ret = chunks[0] <=> chunks[1]

			return -1 if a_chunk == ''
			return ret if ret != 0
		}
	end

	def extract_alpha_or_number_group(item)
		matchdata = /([A-Za-z]+|[\d]+)/.match(item)
		if matchdata.nil?
			["", ""]
		else
			[matchdata[0].sub(/^0+/, ''), item = item[matchdata.offset(0)[1] .. -1]]
		end
	end
end