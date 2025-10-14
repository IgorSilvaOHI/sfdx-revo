@isTest
public class SObjectDomainTest {
  private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';

  private static String lastMethodCalled;

  private static SObjectDomainTest.TestHandler handler;

  static {
    handler = new SObjectDomainTest.TestHandler(false);
    // override its internal trigger detection
    handler.isTriggerExecuting = true;
  }

  /***************************************
   * unit tests
   ***************************************/

  // contexts tests
  @isTest
  static void testBeforeInsert() {
    beforeInsertMode();
    handler.run();
    System.assertEquals(
      'beforeInsert',
      lastMethodCalled,
      'last method should be beforeInsert'
    );
  }

  @isTest
  static void testBeforeUpdate() {
    beforeUpdateMode();
    handler.run();
    System.assertEquals(
      'beforeUpdate',
      lastMethodCalled,
      'last method should be beforeUpdate'
    );
  }

  @isTest
  static void testBeforeDelete() {
    beforeDeleteMode();
    handler.run();
    System.assertEquals(
      'beforeDelete',
      lastMethodCalled,
      'last method should be beforeDelete'
    );
  }

  @isTest
  static void testAfterInsert() {
    afterInsertMode();
    handler.run();
    System.assertEquals(
      'afterInsert',
      lastMethodCalled,
      'last method should be afterInsert'
    );
  }

  @isTest
  static void testAfterUpdate() {
    afterUpdateMode();
    handler.run();
    System.assertEquals(
      'afterUpdate',
      lastMethodCalled,
      'last method should be afterUpdate'
    );
  }

  @isTest
  static void testAfterDelete() {
    afterDeleteMode();
    handler.run();
    System.assertEquals(
      'afterDelete',
      lastMethodCalled,
      'last method should be afterDelete'
    );
  }

  @isTest
  static void testAfterUndelete() {
    afterUndeleteMode();
    handler.run();
    System.assertEquals(
      'afterUndelete',
      lastMethodCalled,
      'last method should be afterUndelete'
    );
  }

  @isTest
  static void testNonTriggerContext() {
    try {
      handler.run();
      System.assert(false, 'the handler ran but should have thrown');
    } catch (SObjectDomain.TriggerHandlerException te) {
      System.assertEquals(
        TRIGGER_CONTEXT_ERROR,
        te.getMessage(),
        'the exception message should match'
      );
    } catch (Exception e) {
      System.assert(
        false,
        'the exception thrown was not expected: ' +
          e.getTypeName() +
          ': ' +
          e.getMessage()
      );
    }
  }

  // test bypass api
  @isTest
  static void testBypassAPI() {
    afterUpdateMode();

    // test a bypass and run handler
    SObjectDomain.bypass('TestHandler');
    handler.run();
    System.assertEquals(
      null,
      lastMethodCalled,
      'last method should be null when bypassed'
    );
    System.assertEquals(
      true,
      SObjectDomain.isBypassed('TestHandler'),
      'test handler should be bypassed'
    );
    resetTest();

    // clear that bypass and run handler
    SObjectDomain.clearBypass('TestHandler');
    handler.run();
    System.assertEquals(
      'afterUpdate',
      lastMethodCalled,
      'last method called should be afterUpdate'
    );
    System.assertEquals(
      false,
      SObjectDomain.isBypassed('TestHandler'),
      'test handler should be bypassed'
    );
    resetTest();

    // test a re-bypass and run handler
    SObjectDomain.bypass('TestHandler');
    handler.run();
    System.assertEquals(
      null,
      lastMethodCalled,
      'last method should be null when bypassed'
    );
    System.assertEquals(
      true,
      SObjectDomain.isBypassed('TestHandler'),
      'test handler should be bypassed'
    );
    resetTest();

    // clear all bypasses and run handler
    SObjectDomain.clearAllBypasses();
    handler.run();
    System.assertEquals(
      'afterUpdate',
      lastMethodCalled,
      'last method called should be afterUpdate'
    );
    System.assertEquals(
      false,
      SObjectDomain.isBypassed('TestHandler'),
      'test handler should be bypassed'
    );
    resetTest();
  }

  // instance method tests
  @isTest
  static void testLoopCount() {
    beforeInsertMode();

    // set the max loops to 2
    handler.setMaxLoopCount(2);

    // run the handler twice
    handler.run();
    handler.run();

    // clear the tests
    resetTest();

    try {
      // try running it. This should exceed the limit.
      handler.run();
      System.assert(
        false,
        'the handler should throw on the 3rd run when maxloopcount is 3'
      );
    } catch (SObjectDomain.TriggerHandlerException te) {
      // we're expecting to get here
      System.assertEquals(null, lastMethodCalled, 'last method should be null');
    } catch (Exception e) {
      System.assert(
        false,
        'the exception thrown was not expected: ' +
          e.getTypeName() +
          ': ' +
          e.getMessage()
      );
    }

    // clear the tests
    resetTest();

    // now clear the loop count
    handler.clearMaxLoopCount();

    try {
      // re-run the handler. We shouldn't throw now.
      handler.run();
      System.assertEquals(
        'beforeInsert',
        lastMethodCalled,
        'last method should be beforeInsert'
      );
    } catch (SObjectDomain.TriggerHandlerException te) {
      System.assert(
        false,
        'running the handler after clearing the loop count should not throw'
      );
    } catch (Exception e) {
      System.assert(
        false,
        'the exception thrown was not expected: ' +
          e.getTypeName() +
          ': ' +
          e.getMessage()
      );
    }
  }

  @isTest
  static void testLoopCountClass() {
    SObjectDomain.LoopCount lc = new SObjectDomain.LoopCount();
    System.assertEquals(5, lc.getMax(), 'max should be five on init');
    System.assertEquals(0, lc.getCount(), 'count should be zero on init');

    lc.increment();
    System.assertEquals(1, lc.getCount(), 'count should be 1');
    System.assertEquals(
      false,
      lc.exceeded(),
      'should not be exceeded with count of 1'
    );

    lc.increment();
    lc.increment();
    lc.increment();
    lc.increment();
    System.assertEquals(5, lc.getCount(), 'count should be 5');
    System.assertEquals(
      false,
      lc.exceeded(),
      'should not be exceeded with count of 5'
    );

    lc.increment();
    System.assertEquals(6, lc.getCount(), 'count should be 6');
    System.assertEquals(
      true,
      lc.exceeded(),
      'should not be exceeded with count of 6'
    );
  }

  // private method tests

  @isTest
  static void testGetHandlerName() {
    System.assertEquals(
      'TestHandler',
      handler.getHandlerName(),
      'handler name should match class name'
    );
  }

  // test virtual methods

  @isTest
  static void testVirtualMethods() {
    TestHandler h = new TestHandler();
    h.onBeforeInsert();
    h.onBeforeUpdate();
    h.onBeforeDelete();
    h.onAfterInsert();
    h.onAfterUpdate();
    h.onAfterDelete();
    h.onAfterUndelete();
  }

  /***************************************
   * testing utilities
   ***************************************/

  private static void resetTest() {
    lastMethodCalled = null;
  }

  // modes for testing

  private static void beforeInsertMode() {
    SObjectDomain.TriggerContext ctx = new SObjectDomain.TriggerContext();

    ctx.Operation = System.TriggerOperation.BEFORE_INSERT;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosById()
      .keySet()
      .iterator()
      .next();

    Account i = new Account(RecordTypeId = recordTypeId, BillingCity = 'São Paulo', BillingPostalCode = '12345-678');

    ctx.NewsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.News = ctx.NewsMap.values();

    handler.setTriggerContext(ctx, true);
  }

  private static void beforeUpdateMode() {
    SObjectDomain.TriggerContext ctx = new SObjectDomain.TriggerContext();

    ctx.Operation = System.TriggerOperation.BEFORE_UPDATE;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosById()
      .keySet()
      .iterator()
      .next();

    Account i = new Account(
      Id = '001HZ000004Ta12YAC',
      RecordTypeId = recordTypeId,
      BillingCity = 'São Paulo',
      BillingPostalCode = '12345-678'
    );

    ctx.NewsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.News = ctx.NewsMap.values();
    ctx.OldsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.Olds = ctx.OldsMap.values();

    handler.setTriggerContext(ctx, true);
  }

  private static void beforeDeleteMode() {
    SObjectDomain.TriggerContext ctx = new SObjectDomain.TriggerContext();

    ctx.Operation = System.TriggerOperation.BEFORE_DELETE;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosById()
      .keySet()
      .iterator()
      .next();

    Account i = new Account(
      Id = '001HZ000004Ta12YAC',
      RecordTypeId = recordTypeId,
      BillingCity = 'São Paulo',
      BillingPostalCode = '12345-678'
    );

    ctx.NewsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.News = ctx.NewsMap.values();
    ctx.OldsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.Olds = ctx.OldsMap.values();

    handler.setTriggerContext(ctx, true);
  }

  private static void afterInsertMode() {
    SObjectDomain.TriggerContext ctx = new SObjectDomain.TriggerContext();

    ctx.Operation = System.TriggerOperation.AFTER_INSERT;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosById()
      .keySet()
      .iterator()
      .next();

    Account i = new Account(
      Id = '001HZ000004Ta12YAC',
      RecordTypeId = recordTypeId,
      BillingCity = 'São Paulo',
      BillingPostalCode = '12345-678'
    );

    ctx.NewsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.News = ctx.NewsMap.values();

    handler.setTriggerContext(ctx, true);
  }

  private static void afterUpdateMode() {
    SObjectDomain.TriggerContext ctx = new SObjectDomain.TriggerContext();

    ctx.Operation = System.TriggerOperation.AFTER_UPDATE;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosById()
      .keySet()
      .iterator()
      .next();

    Account i = new Account(
      Id = '001HZ000004Ta12YAC',
      RecordTypeId = recordTypeId,
      BillingCity = 'São Paulo',
      BillingPostalCode = '12345-678'
    );

    ctx.NewsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.News = ctx.NewsMap.values();
    ctx.OldsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.Olds = ctx.OldsMap.values();

    handler.setTriggerContext(ctx, true);
  }

  private static void afterDeleteMode() {
    SObjectDomain.TriggerContext ctx = new SObjectDomain.TriggerContext();

    ctx.Operation = System.TriggerOperation.AFTER_DELETE;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosById()
      .keySet()
      .iterator()
      .next();

    Account i = new Account(
      Id = '001HZ000004Ta12YAC',
      RecordTypeId = recordTypeId,
      BillingCity = 'São Paulo',
      BillingPostalCode = '12345-678'
    );

    ctx.OldsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.Olds = ctx.OldsMap.values();

    handler.setTriggerContext(ctx, true);
  }

  private static void afterUndeleteMode() {
    SObjectDomain.TriggerContext ctx = new SObjectDomain.TriggerContext();

    ctx.Operation = System.TriggerOperation.AFTER_UNDELETE;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosById()
      .keySet()
      .iterator()
      .next();

    Account i = new Account(
      Id = '001HZ000004Ta12YAC',
      RecordTypeId = recordTypeId,
      BillingCity = 'São Paulo',
      BillingPostalCode = '12345-678'
    );

    ctx.NewsMap = new Map<Id, SObject>{ i.Id => i };
    ctx.News = ctx.NewsMap.values();

    handler.setTriggerContext(ctx, true);
  }

  // test implementation of the TriggerHandler
  private class TestHandler extends SObjectDomain {
    public TestHandler() {
      super();
    }

    public TestHandler(Boolean canSetContext) {
      super(canSetContext);
    }

    protected override Schema.SObjectType getSObjectType() {
      return Account.sObjectType;
    }

    protected override Map<Id, Schema.RecordTypeInfo> getRecordTypeInfosById() {
      return Schema.SObjectType.Account.getRecordTypeInfosById();
    }

    public override void onBeforeInsert() {
      super.onBeforeInsert();
      SObjectDomainTest.lastMethodCalled = 'beforeInsert';
    }

    public override void onBeforeUpdate() {
      super.onBeforeUpdate();
      SObjectDomainTest.lastMethodCalled = 'beforeUpdate';
    }

    public override void onBeforeDelete() {
      super.onBeforeDelete();
      SObjectDomainTest.lastMethodCalled = 'beforeDelete';
    }

    public override void onAfterInsert() {
      super.onAfterInsert();
      SObjectDomainTest.lastMethodCalled = 'afterInsert';
    }

    public override void onAfterUpdate() {
      super.onAfterUpdate();
      SObjectDomainTest.lastMethodCalled = 'afterUpdate';
    }

    public override void onAfterDelete() {
      super.onAfterDelete();
      SObjectDomainTest.lastMethodCalled = 'afterDelete';
    }

    public override void onAfterUndelete() {
      super.onAfterUndelete();
      SObjectDomainTest.lastMethodCalled = 'afterUndelete';
    }
  }
}