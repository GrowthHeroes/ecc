@isTest
public class myClass_Tests {
  @isTest
  static void passingTest() {
    System.Assert(true);
  }

  @isTest
  static void failingTest() {
    System.Assert(false);
  }
}
