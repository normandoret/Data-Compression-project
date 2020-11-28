/**
 * Created by Joonho Yeom
*/

#include <cstdint>
#include <cstring>
#include <iostream>
#include <memory>
#include <vector>

#include "tunstall.h"


/**
 * Serialization Format: [uint32_t, bytes, int, int, bytes]
 * Description: prob list size / prob list  / raw_data_size / compressed_data_size / compressed_data
 * */ 


std::vector<std::uint8_t> tunstall_compress(std::vector<unsigned char> data) {
	crt::Tunstall t;
	t.getProbabilities(data.data(), data.size());

	t.createDecodingTables2();
	t.createEncodingTables();

	int compressed_size;
    int raw_data_size = static_cast<int>(data.size());
	auto *compressed_data = t.compress(data.data(), data.size(), compressed_size);

    uint32_t prob_list_size = t.probabilities.size() * sizeof(t.probabilities[0]);
    uint64_t total_size =
        sizeof(prob_list_size) +
        prob_list_size +
        sizeof(raw_data_size) +
        sizeof(compressed_size) +
        compressed_size;
    std::vector<std::uint8_t> serialized_data(total_size);
    std::uint8_t* dest_ptr = serialized_data.data();
    // Serialize
    {
        // 1. write the probability list size.
        std::memcpy(dest_ptr, &prob_list_size, sizeof(prob_list_size));
        dest_ptr += sizeof(prob_list_size);
        
        // 2. write the probability vector.
        std::memcpy(dest_ptr, t.probabilities.data(), prob_list_size);
        dest_ptr += prob_list_size;
        
        // 3. write the original data size and compressed data size.
        std::memcpy(dest_ptr, &raw_data_size, sizeof(int));
	    dest_ptr += sizeof(int);
        
        std::memcpy(dest_ptr, &compressed_size, sizeof(int));
	    dest_ptr += sizeof(int);

        // 4. write the compressed data size.
        std::memcpy(dest_ptr, compressed_data, compressed_size);
    }
    return serialized_data;
}

std::vector<std::uint8_t> tunstall_decompress(
    std::vector<unsigned char> data) {
    std::vector<std::uint8_t> decompressed_data;
    const unsigned char* src_ptr = data.data();
    crt::Tunstall t;

    // 1. Read the prob list size
    uint32_t prob_list_size = 0;
    std::memcpy(&prob_list_size, src_ptr, sizeof(uint32_t));
    src_ptr += sizeof(uint32_t);

    // 2. Read the prob list
    t.probabilities.resize(prob_list_size / sizeof(t.probabilities[0]));
    std::memcpy(t.probabilities.data(), src_ptr, prob_list_size);
    src_ptr += prob_list_size;

    t.createDecodingTables2();

    // 3. Read the raw data size and compressed data size
    int raw_data_size = 0;
    std::memcpy(&raw_data_size, src_ptr, sizeof(int));
    src_ptr += sizeof(int);
    
    int compressed_data_size = 0;
    std::memcpy(&compressed_data_size, src_ptr, sizeof(int));
    src_ptr += sizeof(int);

    decompressed_data.resize(raw_data_size);

    // 4. Read the compressed data
    t.decompress(src_ptr, compressed_data_size, decompressed_data.data(), raw_data_size);
    return decompressed_data;
}

int main(const int argc, const char* const argv[]) {
    if (argc < 4) {
        std::cout << "Usage: tunstall [c|d] <input_of_file> <output_file>" << std::endl;
        return -1;
    }
    if (argv[1][0] == 'c') {
        // compress
    }
    else if (argv[1][0] == 'd') {
        // decompress
    }
    else {
        std::cerr << "Invalid option: " << argv[1][0] << std::endl;
        return -1;
    }

    return 0;
}
