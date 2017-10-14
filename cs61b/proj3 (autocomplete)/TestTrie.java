import org.junit.Assert;
import ucb.junit.textui;
import org.junit.Test;
import static org.junit.Assert.*;

/** The suite of all JUnit tests for the Trie class.
 *  @author
 */
public class TestTrie {

    /** A dummy test to avoid complaint. */
    @Test
    public void placeholderTest() {

    }

    /** Run the JUnit tests above. */
    public static void main(String[] ignored) {
        //example from the project spec modified
        //http://www.cs61bl.org/su17/materials/proj/proj3/proj3.html
        textui.runClasses(TestTrie.class);
        Trie t = new Trie();
        t.insert("hello");
        t.insert("hey");
        t.insert("goodbye");
        //should all pass
        Assert.assertTrue(t.find("hell", false));
        Assert.assertTrue(t.find("hello", true));
        Assert.assertTrue(t.find("good", false));
        Assert.assertFalse(t.find("bye", false));
        Assert.assertFalse(t.find("heyy", false));
        Assert.assertFalse(t.find("hell", true));
        //should catch Illegal Argument Exceptions
        try {
            t.find("", true);
        } catch (IllegalArgumentException e) {
            System.out.println("caught empty prefix in find");
        }
        try {
            t.insert("");
        } catch (IllegalArgumentException e) {
            System.out.println("caught empty prefix in insert");
        }
    }
}
