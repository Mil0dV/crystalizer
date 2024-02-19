def load_wav_data(filename : String) : Array(Int16)
    file = File.open(filename)

    file.seek(44, IO::Seek::Set) # Adjust here 
    
    samples = [] of Int16
    loop do
        buffer = Bytes.new(4096) # Allocate a byte buffer 
        bytes_read = file.read(buffer)  # Read into the buffer
        break if bytes_read == 0  # Handle end of file

        index = 0
        while index < bytes_read
            left_sample = buffer[index, 2].to_i16(order: :little)
            right_sample = buffer[index + 2, 2].to_i16(order: :little)
            samples << left_sample
            samples << right_sample
            index += 4 # Move to the next pair of samples
        end
    end

    samples
end

wav_data = load_wav_data("CantinaBand60.wav")