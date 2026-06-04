# The Lattice method I

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



def RecYZ1(lx, q, w0, w1):
    Powlx = 2 ** lx
    w = []
    ans_y = []
    ans_q_z = []
    for i in range(len(w0)):
        w.append((w0[i] + w1[i]) % q)
        
        
#     if 0 in w:
    for i in range(len(w0)):
        temp_w = (3 * w[i]) % q
        temp_gcd = gcd(temp_w, q)
        eps = 1
        for eps_0 in range(2):
            for eps_1 in range(2):
                temp_cnt = (- w0[i] * eps_1 - w1[i] * (eps_0 + 2)) % q
                if temp_cnt % temp_gcd == 0:
                    temp_inv = inverse_mod(( temp_w // temp_gcd), (q // temp_gcd))
#                         for k in range(temp_gcd):
#                         temp_z = (temp_inv * (temp_cnt // temp_gcd) + k * q // temp_gcd) % q
                    temp_z = (temp_inv * (temp_cnt // temp_gcd)) % (q // temp_gcd)
                    if temp_z <= q // (Powlx):
                        temp_y = (temp_z + eps) % q
                        ans_y.append(temp_y)
                        ans_q_z.append((q - temp_z) % q)
                        
    for i in range(len(w0)):
        temp_gcd = gcd(w[i], q)
        for eps in range(2):
            temp_cnt = (w1[i] * ( 1 + eps)) % q
            if temp_cnt % temp_gcd == 0:
                temp_inv = inverse_mod(( w[i] // temp_gcd), (q // temp_gcd))
#                 for k in range(temp_gcd):
#                 temp_z = (temp_inv * (temp_cnt // temp_gcd) + k * q // temp_gcd) % q
                temp_z = (temp_inv * (temp_cnt // temp_gcd)) % (q // temp_gcd)
                if temp_z <= q // (Powlx):
                    temp_y = (temp_z - eps) % q
                    ans_y.append(temp_y)
                    ans_q_z.append((q - temp_z) % q)
    print()
    return ans_y, ans_q_z



def Lat(q, lx, w0, w1, ans_y, ans_q_z):  
    Powlx = 2 ** lx
    A = matrix([[1,0,0,0],[0,1,0,0],[0,0,Powlx,0],[0,0,0,q]])
    MT = matrix([[0,0,0,0],[0,0,0,0],[0,0,0,0],[0,0,0,0]])
    temp_c1 = []
    temp_c2 = []
    Y = []
    Z = []
    X = [] 
    X0 = []
    X1 = []
    Flag = []
    for j in range(len(ans_y)):
        temp_y = ans_y[j]
        temp_z = (q - ans_q_z[j]) % q
        for i in range(len(w0)):
            A[0, 3] = w1[i] 
            A[1, 3] = w0[i]
            A[2, 3] = (w1[i] * (Powlx) * temp_y + w0[i] * temp_z * (Powlx)) % q

            MT = A.LLL()
            for mm in range(4):
                if MT[mm,3] == 0 and MT[mm, 2] == (Powlx) or MT[mm, 2] == -(Powlx):
                    if abs(MT[mm, 0]) <= (Powlx) and abs(MT[mm, 0]) >= 0 and abs(MT[mm, 1]) <= (Powlx) and abs(MT[mm, 1]) >= 0:
                        temp_ans = (temp_y * Powlx + abs(MT[mm, 0])) % q
                        X0.append(temp_ans)
                        X1.append((q - (temp_z * Powlx + abs(MT[mm, 1]))) % q)
                        Flag.append(0)

            A[0, 3] = 3 * w1[i] 
            A[1, 3] = 3 * w0[i]
            A[2, 3] = (3 * w1[i] * (Powlx) * temp_y + 3 * w0[i] * (temp_z * (Powlx)) - 2 * w1[i]) % q
            MT = A.LLL()
            
            for mm in range(4):
                if MT[mm,3] == 0 and MT[mm, 2] == (Powlx) or MT[mm, 2] == -(Powlx):
                    if abs(MT[mm, 0]) <= (Powlx) and abs(MT[mm, 0]) >= 0 and abs(MT[mm, 1]) <= (Powlx) and abs(MT[mm, 1]) >= 0:
                        temp_ans = (temp_y * Powlx + abs(MT[mm, 0])) % q
                        X0.append(temp_ans)
                        X1.append((q - (temp_z*Powlx + abs(MT[mm, 1]))) % q)
                        Flag.append(1)
    return X0, X1, Flag


def Check(w0, w1, X0, X1, Flag):
    
    Temp_index = 0
    for i in range(len(X0)):
        summ1 = 0
        summ2 = 0
        for j in range(lx + 1):
            summ1 += TRC0(X0[i], j)
            summ2 += TRC1(X1[i], j)
        summ1 -= 1
        for j in range(len(w1)):
            if (w0[j] * summ2) % q == (w1[j] * summ1) % q:
                Temp_index = i
                print("Rec: t = ", Flag[Temp_index],"\t x = ", ((-1) ** Flag[Temp_index] * (X0[Temp_index] + X1[Temp_index])) % q, "\tx_0 = ", X0[Temp_index],"\tx_1 = ", X1[Temp_index])
    
    return ((-1) ** Flag[Temp_index] * (X0[Temp_index] + X1[Temp_index])) % q


def ImprovedAttack(lx, q, w0, w1):
    Powlx = 2 ** lx
    
    ans_y = []
    ans_q_z = [] 
    X0 = []
    X1 = []
    Flag = []
    
    ans_y, ans_q_z = RecYZ1(lx, q, w0, w1) 
    (X0 , X1, Flag ) = Lat(q, lx, w0, w1, ans_y, ans_q_z)    
    
    if len(X0) == 0:
        return 0
    
    if len(X0) == 1:
        print("Rec : t = ",Flag[0], "\t x = ", ((-1) ** Flag[0] * (X0[0] + X1[0])) % q, "\t x0 = ", ((-1) ** Flag[0] * (X0[0])) % q, "\t x1 = ", ((-1) ** Flag[0] * ( X1[0])) % q)
        return Res_con,((-1) ** Flag[0] * (X0[0] + X1[0])) % q
    
    return Check(w0, w1, X0, X1, Flag)
    
    
        

if __name__ == "__main__":
#     q = 18446744073709551629
#     q = 2 ** 64
#     lx = 13
    
    error = 0
    count = 10000
    rate = 0
    alltime = 0
    con_rate = 0
    for i in range(count):
        q = random_prime(2 ** 65,proof=None,lbound = 2 ** 64) # The prime in [2 ** 64, 2 ** 65]
#         q = 2 ** 64
        lx = 13
        start = (time.time())
        print("i = ", i)
        t, r, per = init(lx, q)
        x0, x1 = Client(lx, q)
        print("Ori : t = ",t, "\t x = ", (x0 + x1) % q)

        w0 = P0(lx, q, x0, t, r, per)
        w1 = P1(lx, q, x1, t, r, per)
        flag = P2(q, w0, w1)

        # Attack: participant P2 is the adversary, who konws the values of lx, q, w0, w1
#         Rec_x = ImprovedAttack(lx, q, w0, w1)
        Rec_x = ImprovedAttack(lx, q, w0, w1)
        if Rec_x == (x0 + x1) % q:
            rate += 1
        
        
        end =(time.time())
        print("Times = ", datetime.datetime.today())
        print("Success Rate = ", rate * 1.0/(i+1), end="\n")
        cost = end - start
        alltime += cost
        print("Time = ", cost)
        print("Avg. Time = {}".format(alltime * 1.0/(i+1)), end="\n")
        print("\n")
    print("Avg. Success Rate = ", rate * 1.0/(count), end="\n")
    print("Avg. Time = {}".format(alltime * 1.0/count), end="\n")
