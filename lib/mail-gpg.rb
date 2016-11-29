require 'mail/gpg'

module Extensions
	#just copied from Rails
	module String
		BLANK_RE = /\A[[:space:]]*\z/

		# A string is blank if it's empty or contains whitespaces only:
		#
		#   ''.blank?       # => true
		#   '   '.blank?    # => true
		#   "\t\n\r".blank? # => true
		#   ' blah '.blank? # => false
		#
		# Unicode whitespace is supported:
		#
		#   "\u00a0".blank? # => true
		#
		# @return [true, false]
		def blank?
			# The regexp that matches blank strings is expensive. For the case of empty
			# strings we can speed up this method (~3.5x) with an empty? call. The
			# penalty for the rest of strings is marginal.
			empty? || BLANK_RE === self
		end 
	end
end

if String.new.respond_to? :'blank?'
	#nop
else
   String.include Extensions::String
end

