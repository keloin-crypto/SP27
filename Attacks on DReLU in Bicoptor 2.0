import sys
import random
import time
from sage.all import ZZ, random_prime


def print_progress(iteration, total, prefix='', suffix='', decimals=1, length=50, fill='█'):
    """Command-line loop progress bar visualization utility."""
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filled_length = int(length * iteration // total)
    bar = fill * filled_length + '-' * (length - filled_length)
    sys.stdout.write(f'\r{prefix} |{bar}| {percent}% {suffix}')
    sys.stdout.flush()
    if iteration == total: 
        print()


def simulate_bicoptor_step5_pure_multiplication(input_x, l, lx, p, verbose=False):
    ring_l = 2**l
    ring_lx = 2**lx
    x = ZZ(input_x)
    R = ZZ.random_element(ring_l)
    
    x0_blind = (x + R) % ring_l 
    x1_blind = (-R) % ring_l
    
    u0 = [(x0_blind >> i) % ring_lx for i in range(lx + 1)]
    u1 = [(ring_l - ((ring_l - x1_blind) >> i)) % ring_lx for i in range(lx + 1)]
    v0 = [(u0[i] + u0[i+1] - 1) % ring_lx for i in range(lx)] + [(u0[lx] - 1) % ring_lx]
    v1 = [(u1[i] + u1[i+1]) % ring_lx for i in range(lx)] + [u1[lx] % ring_lx]

    v0_p = [(ring_lx % p) if val == 0 else (val % p) for val in v0]
    v1_p = [(p + val - ring_lx) % p for val in v1]

    pi_indices = list(range(lx + 1))
    random.shuffle(pi_indices) 
    
    v0_p_shuffled = [v0_p[i] for i in pi_indices]
    v1_p_shuffled = [v1_p[i] for i in pi_indices]

    w0 = []
    w1 = []
    for i in range(lx + 1):
        r_i = ZZ.random_element(1, p) 
        w0.append((v0_p_shuffled[i] * r_i) % p)
        w1.append((v1_p_shuffled[i] * r_i) % p)
        
    return v0_p_shuffled, v1_p_shuffled, w0, w1, x0_blind, x1_blind



def adversary_guess_attack(w0, w1, l, lx, p, true_x0, true_x1, verbose=False):

    ring_lx = 2**lx
    mask_2lx = 2**(2*lx) - 1
    real_g0 = true_x0 & mask_2lx
    real_g1 = true_x1 & mask_2lx
    
    w_sum = [(w0[idx_w] + w1[idx_w]) % p for idx_w in range(lx + 1)]
    has_zero_in_w = (0 in w_sum)
    
    prod_w0 = 1
    prod_w1 = 1
    for w in w0: prod_w0 = (prod_w0 * w) % p
    for w in w1: prod_w1 = (prod_w1 * w) % p
    

    W_ratios_full = []
    for i in range(lx + 1):
        if w1[i] != 0:
            ratio = (w0[i] * pow(w1[i], p - 2, p)) % p
            W_ratios_full.append(ratio)
            

    W_ratios_full_sorted = sorted(W_ratios_full)
            
    if len(W_ratios_full) < 2:
        return real_g0, real_g1, [], 0
        
    R0, R1 = W_ratios_full[0], W_ratios_full[1]
    

    v0_table = [None] * (2**(2*lx))
    v0_prod_table = [None] * (2**(2*lx)) 
    dict_0 = {}
    
    for g0 in range(1, 2**(2*lx)):
        u0 = [(g0 >> i) % ring_lx for i in range(lx + 1)]
        v0 = [(u0[i] + u0[i+1] - 1) % ring_lx for i in range(lx)] + [(u0[lx] - 1) % ring_lx]
        v0_p = [(ring_lx % p) if val == 0 else (val % p) for val in v0]
        
        v0_table[g0] = v0_p
        
        pv0 = 1
        for val in v0_p: pv0 = (pv0 * val) % p
        v0_prod_table[g0] = pv0
        
        for j in range(lx + 1):
            for k in range(lx + 1):
                if j == k: continue
                key = (j, k, v0_p[j], v0_p[k])
                if key not in dict_0:
                    dict_0[key] = []
                dict_0[key].append(g0)
                
    v1_table = [None] * (2**(2*lx))
    v1_prod_table = [None] * (2**(2*lx)) 
    
    for g1 in range(1, 2**(2*lx)):
        u1 = [(- ((2**(2*lx) - g1) >> i)) % ring_lx for i in range(lx + 1)]
        v1 = [(u1[i] + u1[i+1]) % ring_lx for i in range(lx)] + [u1[lx] % ring_lx]
        v1_p = [(p + val - ring_lx) % p for val in v1]
        
        v1_table[g1] = v1_p
        
        pv1 = 1
        for val in v1_p: pv1 = (pv1 * val) % p
        v1_prod_table[g1] = pv1
        
    product_collisions_found = 0
    ultimate_survivors = set() 
    
    mod_2lx = 2**(2*lx)  
    
    for g1 in range(1, mod_2lx):
        v1_arr = v1_table[g1]
        
        if 0 in v1_arr:
            continue
            
        for j in range(lx + 1):
            for k in range(lx + 1):
                if j == k: continue
                
                target_j = (R0 * v1_arr[j]) % p
                target_k = (R1 * v1_arr[k]) % p
                
                key = (j, k, target_j, target_k)
                
                if key in dict_0:
                    for g0 in dict_0[key]:
                        product_collisions_found += 1
                        
                        if (prod_w0 * v1_prod_table[g1]) % p != (prod_w1 * v0_prod_table[g0]) % p:
                            continue
                        
                        v0_arr = v0_table[g0]
                        
                        guess_ratios = []
                        is_legal = True
                        
                        for idx in range(lx + 1):
                            if v1_arr[idx] == 0:
                                is_legal = False
                                break
                            guess_ratios.append((v0_arr[idx] * pow(v1_arr[idx], p - 2, p)) % p)
                            
                        if is_legal and sorted(guess_ratios) == W_ratios_full_sorted:
                            
                            x_rec = (g0 + g1) % mod_2lx
                            
                            keep_candidate = False
                            
                            if 0 <= x_rec < ring_lx:
                                if (x_rec > 0 and has_zero_in_w) or (x_rec == 0 and not has_zero_in_w):
                                    keep_candidate = True
                                    
                            elif mod_2lx - ring_lx <= x_rec < mod_2lx:
                                if (not has_zero_in_w) or (x_rec == mod_2lx - 85):# -85 is the Ghost Zero
                                    keep_candidate = True
                            
                            if keep_candidate:
                                ultimate_survivors.add((g0, g1))

    return list(ultimate_survivors), product_collisions_found


def run_batch_experiments(num_tests=1000, l=64, lx=7, output_file="SingleRoundFilter_attack_statistics.txt"):
    print(f"\nInitiating Batch Attack Experiments (Total: {num_tests} Trials)...")
    print(f"Environmental Parameters: Pure Multiplicative Masking, Truncation lx={lx}\n")
    
    match_count = 0
    perfect_plaintext_recovery_count = 0  
    total_execution_time = 0.0
    
    mod_2lx = 2**(2*lx)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(f"==========================================================\n")
        f.write(f" Bicoptor 2.0 Single-Round Full Fingerprint Filtering Attack Report\n")
        f.write(f" Parameter Configuration: l={l}, lx={lx}\n")
        f.write(f"==========================================================\n\n")
        f.flush() 
        
        print_progress(0, num_tests, prefix='Attack Progress:', suffix='Completed', length=50)
        
        for i in range(num_tests):
            
            lower_bound = 2**lx_val
            upper_bound = 2**(lx_val + 1) - 1
            
            p = random_prime(upper_bound, lbound=lower_bound)
            
            dynamic_input_x = ZZ.random_element(-2**(lx) + 1, 2**(lx))
            random_sign = random.choice([1, -1])
            dynamic_input_x = dynamic_input_x * random_sign
            
            v0_p, v1_p, w0, w1, true_x0, true_x1 = simulate_bicoptor_step5_pure_multiplication(
                input_x = dynamic_input_x, l = l, lx = lx, p = p, verbose = False
            )
            
            mask_2lx = 2**(2*lx) - 1
            real_g0 = true_x0 & mask_2lx
            real_g1 = true_x1 & mask_2lx
            
            w_sum = [(w0[ii] + w1[ii]) % p for ii in range(lx + 1)]
            has_zero_in_w = (0 in w_sum)
            
            true_x_rec = (true_x0 + true_x1) % mod_2lx
            
            f.write(f"\n======================= 0 in w :{has_zero_in_w} ======================")
            f.write(f"\n======================= true x_rec = :{true_x_rec} ======================\n")
            
            # Start timer
            start_time = time.time()
            
            # Execute Single-Round Attack
            ultimate_survivors, col_found = adversary_guess_attack(
                w0, w1, l, lx, p, true_x0, true_x1, verbose = False
            )
            
            # End timer and accumulate
            end_time = time.time()
            trial_time = end_time - start_time
            total_execution_time += trial_time
            
            is_key_matched = (real_g0, real_g1) in ultimate_survivors
            if is_key_matched:
                match_count += 1
                
            recovered_x_set = set((g0 + g1) % mod_2lx for g0, g1 in ultimate_survivors)
            
            is_perfect_plaintext_recovery = (true_x_rec in recovered_x_set) and (len(recovered_x_set) == 1)
            
            if is_perfect_plaintext_recovery:
                perfect_plaintext_recovery_count += 1
            
            f.write(f"======================= the modulo p is :{p} ======================\n")
            f.write(f"[Trial #{i+1:04d}] | Input Plaintext x = {dynamic_input_x} | Exec Time = {trial_time:.4f}s\n")
            f.write(f"  -> Ground Truth Underlying Key : (g0={real_g0}, g1={real_g1})\n")
            
            if is_perfect_plaintext_recovery:
                f.write(f"  -> Plaintext Collapse : ✅ Recovery Successful! All {len(ultimate_survivors)} candidate key(s) collapsed to the unique true solution x_rec = {list(recovered_x_set)[0]}\n")
            elif true_x_rec in recovered_x_set:
                f.write(f"  -> Plaintext Collapse : ⚠️ True plaintext included, but {len(recovered_x_set)-1} residual false plaintext(s) remain\n")
                f.write(f"  -> Candidate Plaintext Set  : {recovered_x_set}\n")
            else:
                f.write(f"  -> Plaintext Collapse : ❌ Attack failed; unable to capture the ground truth plaintext\n")
                
            f.write("-" * 60 + "\n")
            f.flush()
            
            print_progress(i + 1, num_tests, prefix='Attack Progress:', suffix='Completed', length=50)
            
        success_rate = (float(match_count) / float(num_tests)) * 100.0
        perfect_rate = (float(perfect_plaintext_recovery_count) / float(num_tests)) * 100.0
        avg_execution_time = total_execution_time / float(num_tests)
        
        summary = (
            f"\n" + "="*50 + "\n"
            f" Final Experimental Statistical Report (Plaintext Perspective)\n"
            f" ==================================================\n"
            f" Total Test Trials                                   : {num_tests} Trials\n"
            f" Successful Captures of Ground Truth Key             : {match_count} Trials (Probability {success_rate:.2f} %)\n"
            f" Perfect Unique Plaintext Recoveries (Zero Ambiguity): {perfect_plaintext_recovery_count} Trials (Probability {perfect_rate:.2f} %)\n"
            f" --------------------------------------------------\n"
            f" Average Execution Time per Trial                    : {avg_execution_time:.4f} seconds\n"
            f" Total Attack Execution Time                         : {total_execution_time:.4f} seconds\n"
            f" (Detailed execution logs have been securely written to '{output_file}')\n"
            f" ==================================================\n"
        )
        
        f.write(summary)
        f.flush()
        print(summary)

if __name__ == "__main__":
    l_val = 64
    lx_val = 7
    
    
    print(f"[*] Protocol parameter initialization: truncation bits lx = {lx_val}")
    
    run_batch_experiments(
        num_tests=1000, 
        l=l_val, 
        lx=lx_val, 
        output_file=f"SingleRoundFilter_statistics.txt"
    )
