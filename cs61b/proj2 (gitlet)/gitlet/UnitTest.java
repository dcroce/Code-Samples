//package gitlet;
//
//import ucb.junit.textui;
//import org.junit.Test;
//
//import java.io.File;
//
//import static org.junit.Assert.*;
//
///** The suite of all JUnit tests for the gitlet package.
// *  @author
// */
//public class UnitTest {
//
//    /** Run the JUnit tests in the loa package. Add xxxTest.class entries to
//     *  the arguments of runClasses to run other JUnit tests. */
//    public static void main(String[] ignored) {
//        Main.init();
//        Main.add("wug.txt");
//        Main.commit("hey");
//        Repo repo = Command.deserialize(System.getProperty("user.dir") + "/.gitlet/repo");
//        Commit co1 = Command.deserialize(System.getProperty("user.dir")
//                + "/.gitlet/commits/" + repo.getBranches().get(repo.getHead()).getItem());
//        System.out.println(co1.getMessage());
//
//        File test = new File(System.getProperty("user.dir") + "/wug.txt");
//        System.out.println("content in wd:" + Utils.readContents(test));
//        File test2 = new File(System.getProperty("user.dir") + "/notwug.txt");
//        byte[] content2 = Utils.readContents(test2);
//        Utils.writeContents(test, content2);
//
//        Main.checkout("wug.txt");
//    }
//
//    /** A dummy test to avoid complaint. */
//    @Test
//    public void placeholderTest() {
//    }
//
//}
//
//
