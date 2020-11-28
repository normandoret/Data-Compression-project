/**
 * Created by Joonho Yeom
*/

#include <cstdint>
#include <cstring>
#include <memory>
#include <vector>

#include "tunstall.h"


/**
 * Serialization Format: [uint32_t, bytes, int, int, bytes]
 * Description: prob list size / prob list  / raw_data_size / compressed_data_size / compressed_data
 * */ 
// 

std::vector<std::uint8_t> tunstall_compress(std::unique_ptr<unsigned char[]> data, int size) {
	crt::Tunstall t;
	t.getProbabilities(data.get(), size);

	t.createDecodingTables2();
	t.createEncodingTables();

	int compressed_size;
	auto *compressed_data = t.compress(data.get(), size, compressed_size);

    uint32_t prob_list_size = t.probabilities.size() * sizeof(t.probabilities[0]);
    uint64_t total_size =
        sizeof(prob_list_size) +
        prob_list_size +
        sizeof(size) +
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
        std::memcpy(dest_ptr, &size, sizeof(size));
	    dest_ptr += sizeof(size);
        
        std::memcpy(dest_ptr, &compressed_size, sizeof(compressed_size));
	    dest_ptr += sizeof(compressed_size);

        // 4. write the compressed data size.
        std::memcpy(dest_ptr, compressed_data, compressed_size);
    }
    return serialized_data;
}

std::vector<std::uint8_t> tunstall_dempress(
    std::unique_ptr<unsigned char[]> data, int size) {
    std::vector<std::uint8_t> decompressed_data;
    const unsigned char* src_ptr = data.get();
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

int main() {
    
    return 0;
}