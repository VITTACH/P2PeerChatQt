package com.hoppers;

import java.math.BigInteger;
import java.security.SecureRandom;

public class RsaEncrypt {
    private BigInteger mymodulus, publicKey, privateKey;

    private static BigInteger one = BigInteger.ONE;
    private static SecureRandom rnd =new SecureRandom();

    public void init(int len) {
        BigInteger p=BigInteger.probablePrime(len, rnd);
        BigInteger q=BigInteger.probablePrime(len, rnd);
        BigInteger phi=(p.subtract(one)).multiply(q.subtract(one));

        mymodulus = p.multiply(q);
        privateKey=publicKey.modInverse(phi);
    }

    public BigInteger getPublic() {
        return publicKey;
    }

    public BigInteger getModulu() {
        return mymodulus;
    }

    BigInteger encrypt(BigInteger message) {
        return
        message.modPow(publicKey, mymodulus);
    }

    BigInteger decrypt(BigInteger encrypt) {
        return
        encrypt.modPow(privateKey,mymodulus);
    }

    RsaEncrypt() {
        publicKey = BigInteger.probablePrime(1024, rnd);
    }

    public void setPublic(BigInteger _Key) {
        this.publicKey = _Key;
    }

    public void setModulu(BigInteger smod) {
        this.mymodulus = smod;
    }

    public String toString() {
        String s = "";
        s += "public =" + publicKey  + "\n";
        s += "private=" + privateKey + "\n";
        s += "modulus=" + mymodulus;
        return s;
    }
}
