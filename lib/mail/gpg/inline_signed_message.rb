require 'mail/gpg/verified_part'

module Mail
  module Gpg
    class InlineSignedMessage < Mail::Message

      def self.setup(signed_mail, options = {})
        if signed_mail.multipart?
          self.new do
            global_verify_result = []
            signed_mail.header.fields.each do |field|
              header[field.name] = field.value
            end
            signed_mail.parts.each do |part|
              if Mail::Gpg.signed_inline?(part)
                signed_text = part.body.to_s
                success, vr = GpgmeHelper.inline_verify(signed_text, options)
                p = VerifiedPart.new(part)
                if success
                  p.body self.class.strip_inline_signature signed_text
                end
                p.verify_result vr
                global_verify_result << vr
                add_part p
              else
                add_part part
              end
            end
            verify_result global_verify_result
          end # of multipart
        else
          self.new do
            signed_mail.header.fields.each do |field|
              header[field.name] = field.value
            end
            signed_text = signed_mail.body.to_s
            success, vr = GpgmeHelper.inline_verify(signed_text, options)
            if success
              body self.class.strip_inline_signature signed_text
            else
              body signed_text
            end
            verify_result vr
          end
        end
      end

      END_SIGNED_TEXT = '-----END.*?-----'
      BEGIN_SIGNED_TEXT= /^(-----BEGIN.*?SIGN.*?-----)\s*$/


      # utility method to remove inline signature and related pgp markers
      def self.strip_inline_signature(signed_text)
        skip_next = false
        stripped_lines = []
        lines = signed_text.split(/\n/)

        lines.each do |line|
          if line =~ BEGIN_SIGNED_TEXT
            skip_next = true
            next
          end
          if skip_next
            if line =~ /^Hash:.*/
              skip_next = false
              next
            end
            #do nothing if not Hash...
          end
          next if END_SIGNED_TEXT
          stripped_lines << line
        end
        stripped_lines.join("\n") 
      end

    end
  end
end


