import org.junit.Assert;
import ucb.junit.textui;
import org.junit.Test;

import java.util.Iterator;

import static org.junit.Assert.*;

/** The suite of all JUnit tests for the Autocomplete class.
 *  @author
 */
public class TestAutocomplete {

    /** A dummy test to avoid complaint. */
    @Test
    public void placeholderTest() {
        //example from the project specs modified
        //http://www.cs61bl.org/su17/materials/proj/proj3/proj3.html
        String[] terms = new String[7];
        terms[0] = "smog";
        terms[1] = "buck";
        terms[2] = "sad";
        terms[3] = "spite";
        terms[4] = "spit";
        terms[5] = "spy";
        terms[6] = "smogs";
        double[] weights = new double[7];
        weights[0] = 5;
        weights[1] = 10;
        weights[2] = 12;
        weights[3] = 20;
        weights[4] = 15;
        weights[5] = 7;
        weights[6] = 5;
        Autocomplete ac = new Autocomplete(terms, weights);
        //should all pass
        String[] emptyPrefix = {"spite", "spit", "sad"};
        Iterable<String> answer1 = ac.topMatches("", 3);
        Iterator<String> iter1 = answer1.iterator();
        for (int i = 0; i < emptyPrefix.length; i++) {
            Assert.assertEquals(emptyPrefix[i], iter1.next());
        }
        String[] bPrefix = {"buck"};
        Iterable<String> answer2 = ac.topMatches("b", 5);
        Iterator<String> iter2 = answer2.iterator();
        for (int i = 0; i < bPrefix.length; i++) {
            Assert.assertEquals(bPrefix[i], iter2.next());
        }
        String[] fullWordPrefix = {"spy"};
        Iterable<String> answer3 = ac.topMatches("spy", 2);
        Iterator<String> iter3 = answer3.iterator();
        for (int i = 0; i < fullWordPrefix.length; i++) {
            Assert.assertEquals(fullWordPrefix[i], iter3.next());
        }
        String[] sameValPrefix = {"smog", "smogs"};
        Iterable<String> answer4 = ac.topMatches("smog", 2);
        Iterator<String> iter4 = answer4.iterator();
        for (int i = 0; i < sameValPrefix.length; i++) {
            Assert.assertEquals(sameValPrefix[i], iter4.next());
        }
        //should catch Illegal Argument Exceptions
        try {
            Autocomplete failAc = new Autocomplete(new String[5], new double[4]);
        } catch (IllegalArgumentException e) {
            System.out.println("caught non equal lengths of terms and weights");
        }
        try {
            String[] okTerm = new String[1];
            okTerm[0] = "ok";
            double[] failWeight = new double[1];
            failWeight[0] = -1;
            Autocomplete failAc = new Autocomplete(okTerm, failWeight);
        } catch (IllegalArgumentException e) {
            System.out.println("caught negative weight");
        }
        try {
            Iterable<String> failMatches = ac.topMatches("", -1);
        } catch (IllegalArgumentException e) {
            System.out.println("caught negative k in topMatches");
        }
    }

    /** Run the JUnit tests above. */
    public static void main(String[] ignored) {
        textui.runClasses(TestAutocomplete.class);
    }
}
