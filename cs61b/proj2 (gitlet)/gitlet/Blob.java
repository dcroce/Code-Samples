package gitlet;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.Serializable;

/**
 * Created by kyoung on 7/14/17.
 */
public class Blob implements Serializable {

    //Fields
    private byte[] file = null;
    private String id;

    //Constructor
    public Blob(String name) throws FileNotFoundException {
        File currDir = new File(System.getProperty("user.dir"));
        for (File files : currDir.listFiles()) {
            if (files.getName().equals(name)) {
                file = Utils.readContents(files);
                id = this.assignHashValue(name);
                break;
            }
        }
        if (file == null) {
            throw new FileNotFoundException();
        }
    }

    //Getters
    public byte[] getFile() {
        return file;
    }

    public String getId() {
        return id;
    }

    //Methods
    public String assignHashValue(String name) {
        return Utils.sha1(file, name);
    }

}
