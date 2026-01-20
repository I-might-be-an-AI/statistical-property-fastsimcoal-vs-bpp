#!/usr/bin/env python3

import glob
import re
from collections import defaultdict

# --- Configuration ---
NUM_LOCI = 500
LOCUS_LENGTH = 500

# --- NEW: Define the mapping from ARP names to your BPP control file names ---
# This is the main change. Edit this dictionary to match your .ctl files.
population_name_map = {
    "Sample 1": "A",
    "Sample 2": "B",
    "Sample 3": "C"
}

# --- Data storage ---
haplotype_data = defaultdict(list)
haplotype_to_population = {}

def get_dna_segments(line_parts):
    """Identifies and returns a list of DNA segments from a list of strings."""
    dna_sequences = []
    for part in line_parts:
        if re.fullmatch(r'[ACGTN?]+', part, re.IGNORECASE):
            dna_sequences.append(part)
    return dna_sequences

# --- PASS 1: READ ALL ARP FILES ---
print("--- Reading and parsing all .arp files ---")
arp_files = sorted(glob.glob("**/*.arp", recursive=True))

if not arp_files:
    print("Error: No .arp files found in this directory or subdirectories.")
else:
    for path in arp_files:
        print(f"Reading {path!r}...")
        current_population_name = None
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                stripped_line = line.strip()
                if not stripped_line:
                    continue
                if 'SampleName=' in stripped_line:
                    match = re.search(r'SampleName="([^"]+)"', stripped_line)
                    if match:
                        current_population_name = match.group(1)
                if current_population_name and stripped_line.startswith(tuple(str(i) for i in range(10))):
                    parts = re.split(r'\s+', stripped_line)
                    haplotype_id = parts[0]
                    haplotype_to_population[haplotype_id] = current_population_name
                    dna_sequences_on_line = get_dna_segments(parts)
                    haplotype_data[haplotype_id].extend(dna_sequences_on_line)

    # --- DATA VERIFICATION ---
    if not haplotype_data:
        print("\nError: No haplotype data was parsed. Please check the .arp file format.")
    else:
        first_hap_id = list(haplotype_data.keys())[0]
        actual_length = len(haplotype_data[first_hap_id][0])
        expected_length = NUM_LOCI * LOCUS_LENGTH
        print(f"\nParsing complete. Found {len(haplotype_data)} total haplotypes.")
        if actual_length != expected_length:
            print(f"Warning: Parsed sequence length is {actual_length}, but expected {expected_length}.")
        print(f"Proceeding to split each sequence into {NUM_LOCI} loci of {LOCUS_LENGTH} bases.")

    # --- PASS 2: WRITE THE BPP-COMPATIBLE FILES ---
    original_haplotype_ids = sorted(haplotype_data.keys(), key=lambda x: [int(c) for c in x.split('_')])
    num_total_haplotypes = len(original_haplotype_ids)

    # --- Write the BPP sequence file ('loci.txt') ---
    print("\n--- Writing data to BPP sequence file ---")
    with open("loci.txt", "w", encoding="utf-8") as bpp_file:
        for i in range(NUM_LOCI):
            print(f"Writing Locus {i + 1}/{NUM_LOCI}...")
            num_bases = LOCUS_LENGTH
            bpp_file.write(f"{num_total_haplotypes}  {num_bases}\n\n")
            for original_hap_id in original_haplotype_ids:
                full_sequence = haplotype_data[original_hap_id][0]
                start_pos = i * LOCUS_LENGTH
                end_pos = start_pos + LOCUS_LENGTH
                locus_sequence = full_sequence[start_pos:end_pos]
                
                # Use the map to get the correct population name (e.g., 'A')
                original_pop_name = haplotype_to_population[original_hap_id]
                bpp_pop_name = population_name_map.get(original_pop_name, original_pop_name) # Fallback to original if not in map
                
                bpp_name = f"{bpp_pop_name}^{original_hap_id}"
                bpp_file.write(f"{bpp_name}  {locus_sequence}\n")
            if i < NUM_LOCI - 1:
                bpp_file.write("\n\n")
    print("\nBPP sequence file 'loci.txt' created successfully. ✅")

    # --- Write the Imap file ('imap.txt') ---
    print("\n--- Writing data to Imap file ---")
    with open("imap.txt", "w", encoding="utf-8") as imap_file:
        for original_hap_id in original_haplotype_ids:
            # Use the map to get the correct population name (e.g., 'A')
            original_pop_name = haplotype_to_population[original_hap_id]
            bpp_pop_name = population_name_map.get(original_pop_name, original_pop_name) # Fallback to original if not in map
            
            imap_file.write(f"{original_hap_id}\t{bpp_pop_name}\n")
            
    print("\nImap file 'imap.txt' created successfully. ✅")