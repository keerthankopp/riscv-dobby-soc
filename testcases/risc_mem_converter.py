# -*- coding: utf-8 -*-
"""
Created on Sun Jul 23 03:01:13 2023

@author: Rohan
"""

def convert_to_32_bit_words(input_file, output_file):
    with open(input_file, 'r') as f_input:
        with open(output_file, 'w') as f_output:
            for line in f_input:
                # Remove leading/trailing whitespaces and split the line into bytes
                bytes_list = line.strip().split()

                # Join the bytes into a 32-bit word and write it to a new line
                for i in range(3, -1, -1):
                    word = ''.join(bytes_list[i::4])
                    f_output.write(word + '\n')
# Example usage
input_file = 'all_asm_norvc.txt'
output_file = 'output.txt'
convert_to_32_bit_words(input_file, output_file)
