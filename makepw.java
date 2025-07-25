import java.security.MessageDigest;
import java.util.Base64;

public class makepw {
    public static void main(String[] args) throws Exception {
        String password = "admin";
        MessageDigest md = MessageDigest.getInstance("SHA-512/256");

        byte[] pwBytes = password.getBytes("UTF-8");
        byte[] salt = {0,0,0,0,0,0,0,0};

        byte[] bytes = new byte[pwBytes.length + salt.length];
        System.arraycopy(pwBytes, 0, bytes, 0, pwBytes.length);
        System.arraycopy(salt, 0, bytes, pwBytes.length, salt.length);

        md.update(bytes);
        byte[] digest = md.digest();

        // Java 8+ Base64 encoder
        String hash = "{" + "SHA-512/256" + "|"
            + Base64.getEncoder().encodeToString(digest) + "|"
            + Base64.getEncoder().encodeToString(salt) + "}";

        System.out.println(hash);
    }
}
