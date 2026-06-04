# The enumeration method

import random
import math
import datetime
import time

def init(lx, q):
    # random bit t
    t = random.randint(0, 1) 
    
    # random numbers r_0, ..., r_(l_x), r_* 
    r = []  
    for i in range(lx + 2):
        r.append(random.randint(1, q-1))
        
    # Permutation 
    per = [ _ for _ in range(lx + 2)]
    random.shuffle(per)
    
    return t, r, per
    
    
def Client(lx, q):
    # generate x
    sign = random.randint(0, 1)
    x = random.randint(0, 2 ** lx - 1)
    if sign == 1:
        x = q - x 
    
    x0 = random.randint(0, q)
    x1 = (x - x0) % q 
        
    return x0, x1


def TRC0(x, i):
    return x >> i


def TRC1(x, i):
    return q - ((q - x) >> i)


def P0(lx, q, x0, t, r, per):
    x_0 = ((-1) ** t * x0) % q
    u0 = []
    
    for i in range(lx + 1):
        temp = TRC0(x_0, i)
        u0.append(temp)
    u0.append((-1) ** t)
    
    v0 = []
    for i in range(len(u0) - 1):
        temp = 0
        for j in range(i, len(u0) - 1):
            temp += u0[j]
            temp %= q
        v0.append(temp - 1)
    v0.append(((-1) ** t + 3 * u0[0] -1) % q)
    
    for i in range(len(v0)):
        v0[i] = (v0[i] * r[i]) % q
        
    w0 = []
    for i in range(lx + 2):
        w0.append(v0[per[i]])
        
    return w0
    
         
def P1(lx, q, x1, t, r, per):
    x_1 = ((-1) ** t * x1) % q
    u1 = []
    
    for i in range(lx + 1):
        temp = TRC1(x_1, i)
        u1.append(temp)
    u1.append(0)
    
    v1 = []
    for i in range(len(u1) - 1):
        temp = 0
        for j in range(i, len(u1) - 1):
            temp += u1[j]
            temp %= q
        v1.append(temp)
    v1.append((3 * u1[0]) % q)
    
    for i in range(len(v1)):
        v1[i] = (v1[i] * r[i]) % q
        
    w1 = []
    for i in range(lx + 2):
        w1.append(v1[per[i]])
        
    return w1


def P2(q, w0, w1):
    w = []
    for i in range(len(w0)):
        w.append((w0[i] + w1[i]) % q)
        
    return (0 in w)
            

def New_Attack(lx, q, w0, w1):
    ans_x0 = []
    ans_x1 = []
    ans_x = []
    summ = 0
    indexpos = 0
    for i in range(len(w0)):
        w = (w0[i] + w1[i]) % q
        temp_gcd = gcd((3 * w) % q, q)
        temp_inv = inverse_mod(((3 * w) % q // temp_gcd), (q // temp_gcd))
        print("Temp_gcd = ", temp_gcd, end="\t")
        
        # t = 0
        for j in range(2 ** lx):
            tempx = j
            if ((3 * w0[i] * tempx) % q) % temp_gcd == 0:
                temp_x0 = ((temp_inv * 3 * w0[i] * tempx) // (temp_gcd)) % (q // temp_gcd)
                temp_x1 = (tempx - temp_x0) % q
                if temp_gcd != q:
                    for k in range(temp_gcd):
                        if temp_x0 + k * q // temp_gcd < q:
                            tt_x0 = temp_x0 + k * q // temp_gcd
                            tt_x1 = (tempx - (temp_x0 + k * q // temp_gcd)) % q
                            if (3 * w * tt_x0) % q == (3 * w0[i] * tempx) % q:
                                cnt_0 =(TRC1(tt_x1, lx)) % q
                                cnt_1 = (TRC0(tt_x0, lx) - 1) % q
                                cnt0 = (TRC1(tt_x1, lx - 3) + TRC1(tt_x1, lx - 2) + TRC1(tt_x1, lx - 1) + TRC1(tt_x1, lx)) % q
                                cnt1 = (TRC0(tt_x0, lx - 3) + TRC0(tt_x0, lx - 2) + TRC0(tt_x0, lx - 1) + TRC0(tt_x0, lx) - 1) % q
                                temp_summ = 0
                                for tt in range(len(w0)):
                                    if (w0[tt] * cnt0) % q == (w1[tt] * cnt1) % q:
                                        temp_summ += 1
                                    if (w0[tt] * cnt_0) % q == (w1[tt] * cnt_1) % q:
                                        temp_summ += 1
                                if temp_summ == 2:
                                    ans_x0.append(tt_x0)
                                    ans_x1.append(tt_x1)
                                    ans_x.append(tempx)
                                    summ += 1
#         for j in range(2 ** lx):
            tempx = q - j
            if ((3 * w0[i] * tempx) % q) % temp_gcd == 0:
                temp_x0 = ((temp_inv * 3 * w0[i] * tempx) // (temp_gcd)) % (q // temp_gcd)
                temp_x1 = (tempx - temp_x0) % q
                if temp_gcd != q:
                    for k in range(temp_gcd):
                        if temp_x0 + k * q // temp_gcd < q:
                            tt_x0 = temp_x0 + k * q // temp_gcd
                            tt_x1 = (tempx - (temp_x0 + k * q // temp_gcd)) % q
                            if (3 * w * tt_x0) % q == (3 * w0[i] * tempx) % q:
                                cnt_0 = (TRC1(tt_x1, lx)) % q
                                cnt_1 = (TRC0(tt_x0, lx) - 1) % q
                                cnt0 = (TRC1(tt_x1, lx - 3) + TRC1(tt_x1, lx - 2) + TRC1(tt_x1, lx - 1) + TRC1(tt_x1, lx)) % q
                                cnt1 = (TRC0(tt_x0, lx - 3) + TRC0(tt_x0, lx - 2) + TRC0(tt_x0, lx - 1) + TRC0(tt_x0, lx) - 1) % q
                                temp_summ = 0
                                for tt in range(len(w0)):
                                    if (w0[tt] * cnt0) % q == (w1[tt] * cnt1) % q:
                                        temp_summ += 1
                                    if (w0[tt] * cnt_0) % q == (w1[tt] * cnt_1) % q:
                                        temp_summ += 1
                                if temp_summ == 2:
                                    ans_x0.append(tt_x0)
                                    ans_x1.append(tt_x1)
                                    ans_x.append(tempx)
                                    summ += 1
        indexpos = summ
        
        # t = 1
        for j in range(2 ** lx):
            tempx = j
            if ((3 * w0[i] * tempx + 2 * w1[i]) % q) % temp_gcd == 0:
                temp_x0 = ((temp_inv * (3 * w0[i] * tempx + 2 * w1[i])) // (temp_gcd)) % (q // temp_gcd)
                temp_x1 = (tempx - temp_x0) % q
                if temp_gcd != q:
                    for k in range(temp_gcd):
                        if temp_x0 + k * q // temp_gcd < q:
                            tt_x0 = temp_x0 + k * q // temp_gcd
                            tt_x1 = (tempx - (temp_x0 + k * q // temp_gcd)) % q
                            if (3 * w * tt_x0) % q == (3 * w0[i] * tempx + 2 * w1[i]) % q:
                                cnt_0 = (TRC1(tt_x1, lx)) % q
                                cnt_1 = (TRC0(tt_x0, lx) - 1) % q
                                cnt0 = (TRC1(tt_x1, lx - 3) + TRC1(tt_x1, lx - 2) + TRC1(tt_x1, lx - 1) + TRC1(tt_x1, lx)) % q
                                cnt1 = (TRC0(tt_x0, lx - 3) + TRC0(tt_x0, lx - 2) + TRC0(tt_x0, lx - 1) + TRC0(tt_x0, lx) - 1) % q
                                temp_summ = 0
                                for tt in range(len(w0)):
                                    if (w0[tt] * cnt0) % q == (w1[tt] * cnt1) % q:
                                        temp_summ += 1
                                    if (w0[tt] * cnt_0) % q == (w1[tt] * cnt_1) % q:
                                        temp_summ += 1
                                if temp_summ == 2:
                                    ans_x0.append(tt_x0)
                                    ans_x1.append(tt_x1)
                                    ans_x.append(tempx)
                                    summ += 1
#         for j in range(2 ** lx):
            tempx = q - j
            if ((3 * w0[i] * tempx + 2 * w1[i]) % q) % temp_gcd == 0:
                temp_x0 = ((temp_inv * (3 * w0[i] * tempx + 2 * w1[i])) // (temp_gcd)) % (q // temp_gcd)
                if temp_gcd != q:
                    for k in range(temp_gcd):
                        if temp_x0 + k * q // temp_gcd < q:
                            tt_x0 = temp_x0 + k * q // temp_gcd
                            tt_x1 = (tempx - (temp_x0 + k * q // temp_gcd)) % q
                            if (3 * w * tt_x0) % q == (3 * w0[i] * tempx + 2 * w1[i]) % q:
                                cnt_0 = (TRC1(tt_x1, lx)) % q
                                cnt_1 = (TRC0(tt_x0, lx) - 1) % q
                                cnt0 = (TRC1(tt_x1, lx - 3) + TRC1(tt_x1, lx - 2) + TRC1(tt_x1, lx - 1) + TRC1(tt_x1, lx)) % q
                                cnt1 = (TRC0(tt_x0, lx - 3) + TRC0(tt_x0, lx - 2) + TRC0(tt_x0, lx - 1) + TRC0(tt_x0, lx) - 1) % q
                                temp_summ = 0
                                for tt in range(len(w0)):
                                    if (w0[tt] * cnt0) % q == (w1[tt] * cnt1) % q:
                                        temp_summ += 1
                                    if (w0[tt] * cnt_0) % q == (w1[tt] * cnt_1) % q:
                                        temp_summ += 1
                                if temp_summ == 2:
                                    ans_x0.append(tt_x0)
                                    ans_x1.append(tt_x1)
                                    ans_x.append(tempx)
                                    summ += 1
               
    print("\nSumm = ", summ)
# verification    
    if (summ) == 1:
        Sig = 1
        for i in range(len(w0)):
            w = (3 * (w0[i] + w1[i])) % q
            temp_cnt0 = (w * ans_x0[0]) % q
            temp_cnt1 = (3 * w0[i] * (ans_x0[0] + ans_x1[0])) % q
            if temp_cnt0 == temp_cnt1:
                Sig = 0
        print("Rec : t = ", Sig, "\t  x = ", ((-1) ** Sig *(ans_x0[0] + ans_x1[0])) % q, "\t x_0 = ", ans_x0[0], "\t  x_1 = ", ans_x1[0])
        return ((-1) ** Sig *(ans_x0[0] + ans_x1[0])) % q
    
# First round inspection
    sol_x0 = []
    sol_x1 = []
    ans_summ = 0
    index_temp = 0
    for i in range(len(w0)):
        for j in range(len(ans_x0)):
            cnt0 = (TRC1(ans_x1[j], lx - 1) + TRC1(ans_x1[j], lx)) % q
            cnt1 = (TRC0(ans_x0[j], lx - 1) + TRC0(ans_x0[j], lx) - 1) % q
            if (w0[i] * cnt0) % q == (w1[i] * cnt1) % q:
                sol_x0.append(ans_x0[j])
                sol_x1.append(ans_x1[j])
                ans_summ += 1
                index_temp = j
                
    if (ans_summ) == 1:
        Sig = 1
        for i in range(len(w0)):
            w = (3 * (w0[i] + w1[i])) % q
            temp_cnt0 = (w * sol_x0[0]) % q
            temp_cnt1 = (3 * w0[i] * (sol_x0[0] + sol_x1[0])) % q
            if temp_cnt0 == temp_cnt1:
                Sig = 0
        print("Rec : t = ", Sig, "\t  x = ", ((-1) ** Sig *(sol_x0[0] + sol_x1[0])) % q, "\t x_0 = ", sol_x0[0], "\t  x_1 = ", sol_x1[0])
        return ((-1) ** Sig *(sol_x0[0] + sol_x1[0])) % q
    
# Second round inspection
    sol1_x0 = []
    sol1_x1 = []
    ans_summ = 0
    index_temp = 0
    for i in range(len(w0)):
        for j in range(len(sol_x0)):
            cnt0 = (TRC1(sol_x1[j], lx - 2) + TRC1(sol_x1[j], lx - 1) + TRC1(sol_x1[j], lx)) % q
            cnt1 = (TRC0(sol_x0[j], lx - 2) + TRC0(sol_x0[j], lx - 1) + TRC0(sol_x0[j], lx) - 1) % q
            if (w0[i] * cnt0) % q == (w1[i] * cnt1) % q:
                sol1_x0.append(sol_x0[j])
                sol1_x1.append(sol_x1[j])
                ans_summ += 1
                index_temp = j
                
    if (ans_summ) == 1:
        Sig = 1
        for i in range(len(w0)):
            w = ((w0[i] + w1[i])) % q
            temp_cnt0 = (w * sol1_x0[0]) % q
            temp_cnt1 = (w0[i] * (sol1_x0[0] + sol1_x1[0])) % q
            if temp_cnt0 == temp_cnt1:
                Sig = 0
        print("Rec : t = ", Sig, "\t  x = ", ((-1) ** Sig *(sol1_x0[0] + sol1_x1[0])) % q, "\t x_0 = ", sol1_x0[0], "\t  x_1 = ", sol1_x1[0])
        return ((-1) ** Sig *(sol1_x0[0] + sol1_x1[0])) % q
    return 0
        
    
            


if __name__ == "__main__":
#     q = 18446744073709551629
    q = 2 ** 64
    lx = 13
    
    error = 0
    count = 10
    rate = 0
    alltime = 0
    for i in range(count):
        start = time.time()
        print("\ni = ", i)
        t, r, per = init(lx, q)
        x0, x1 = Client(lx, q)
        print("Ori : t = ",t, "\t x = ", (x0 + x1) % q)

        w0 = P0(lx, q, x0, t, r, per)
        w1 = P1(lx, q, x1, t, r, per)
        flag = P2(q, w0, w1)

        # Attack: participant P2 is the adversary, who konws the values of lx, q, w0, w1
        Rec_x = New_Attack(lx, q, w0, w1)
        if Rec_x == (x0 + x1) % q:
            rate += 1
        
        end =int(time.time())
        print("Times = ", datetime.datetime.today())
        print("Success Rate = ", rate * 1.0/(i+1), end="\n")
        cost = end - start
        alltime += cost
        print("Time = ", cost)
        print("Avg. Time = {}".format(alltime/(i+1)), end="\n\n")
    print("Avg. Time = {}".format(alltime/count), end="\n\n")
        
        
