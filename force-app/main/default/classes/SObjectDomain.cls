public abstract with sharing class SObjectDomain {
  // static map of handlername, times run() was invoked
  private static Map<String, LoopCount> loopCountMap;
  private static Set<String> bypassedHandlers;

  // the current context of the trigger, overridable in tests
  @TestVisible
  protected TriggerContext context;

  // the current context of the trigger, overridable in tests
  @TestVisible
  private Boolean isTriggerExecuting;

  // static initialization
  static {
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
  }

  // constructor
  public SObjectDomain() {
    this.setTriggerContext();
  }

  public SObjectDomain(Boolean canSetContext) {
    if (canSetContext) {
      this.setTriggerContext();
    }
  }

  abstract protected Schema.SObjectType getSObjectType();

  abstract protected Map<Id, Schema.RecordTypeInfo> getRecordTypeInfosById();

  // ***************************************
  // ******* public instance methods *******
  // ***************************************

  // main method that will be called during execution
  public void run() {
    if (!validateRun())
      return;

    addToLoopCount();

    //System.debug('CanRun: ' + this.context.CanRun);

    if (this.context.CanRun == null) {
      this.context.CanRun = true;
    }

    // dispatch to the correct handler method
    if (
      this.context.Operation == System.TriggerOperation.BEFORE_INSERT &&
      this.context.CanRun
    ) {
      this.onBeforeInsert();
    } else if (
      this.context.Operation == System.TriggerOperation.BEFORE_UPDATE &&
      this.context.CanRun
    ) {
      this.onBeforeUpdate();
    } else if (
      this.context.Operation == System.TriggerOperation.BEFORE_DELETE &&
      this.context.CanRun
    ) {
      this.onBeforeDelete();
    } else if (
      this.context.Operation == System.TriggerOperation.AFTER_INSERT &&
      this.context.CanRun
    ) {
      this.onAfterInsert();
    } else if (
      this.context.Operation == System.TriggerOperation.AFTER_UPDATE &&
      this.context.CanRun
    ) {
      this.onAfterUpdate();
    } else if (
      this.context.Operation == System.TriggerOperation.AFTER_DELETE &&
      this.context.CanRun
    ) {
      this.onAfterDelete();
    } else if (
      this.context.Operation == System.TriggerOperation.AFTER_UNDELETE &&
      this.context.CanRun
    ) {
      this.onAfterUndelete();
    }
  }

  public void setMaxLoopCount(Integer max) {
    String handlerName = getHandlerName();
    if (!SObjectDomain.loopCountMap.containsKey(handlerName)) {
      SObjectDomain.loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      SObjectDomain.loopCountMap.get(handlerName).setMax(max);
    }
  }

  public void clearMaxLoopCount() {
    this.setMaxLoopCount(-1);
  }

  // ***************************************
  // ******** public static methods ********
  // ***************************************

  public static void bypass(String handlerName) {
    SObjectDomain.bypassedHandlers.add(handlerName);
  }

  public static void clearBypass(String handlerName) {
    SObjectDomain.bypassedHandlers.remove(handlerName);
  }

  public static Boolean isBypassed(String handlerName) {
    return SObjectDomain.bypassedHandlers.contains(handlerName);
  }

  public static void clearAllBypasses() {
    SObjectDomain.bypassedHandlers.clear();
  }

  // ***************************************
  // ******* private instancemethods *******
  // ***************************************

  @TestVisible
  private void setTriggerOperation(System.TriggerOperation op) {
    context.Operation = op;
  }

  @TestVisible
  private void setTriggerContext() {
    TriggerContext trgContext = new TriggerContext();

    trgContext.Operation = Trigger.operationType;

    switch on trgContext.Operation {
      when BEFORE_INSERT {
        trgContext.News = Trigger.new.Clone();
      }
      when BEFORE_UPDATE {
        trgContext.News = Trigger.new.Clone();
        trgContext.NewsMap = Trigger.NewMap.Clone();
        trgContext.Olds = Trigger.old.Clone();
        trgContext.OldsMap = Trigger.OldMap.Clone();
      }
      when AFTER_INSERT {
        trgContext.News = Trigger.new.Clone();
        trgContext.NewsMap = Trigger.NewMap.Clone();
      }
      when AFTER_UPDATE {
        trgContext.News = Trigger.new.Clone();
        trgContext.NewsMap = Trigger.NewMap.Clone();
        trgContext.Olds = Trigger.old.Clone();
        trgContext.OldsMap = Trigger.OldMap.Clone();
      }
      when AFTER_DELETE {
        trgContext.Olds = Trigger.old.Clone();
        trgContext.OldsMap = Trigger.OldMap.Clone();
      }
      when AFTER_UNDELETE {
        trgContext.News = Trigger.new.Clone();
        trgContext.NewsMap = Trigger.NewMap.Clone();
      }
      when BEFORE_DELETE {
        trgContext.Olds = Trigger.old.Clone();
        trgContext.OldsMap = Trigger.OldMap.Clone();
      }
    }

    this.setTriggerContext(trgContext, false);
  }

  @TestVisible
  private void setTriggerContext(TriggerContext mthContext, Boolean testMode) {
    if (!Trigger.isExecuting && !testMode) {
      this.isTriggerExecuting = false;
      return;
    } else {
      this.isTriggerExecuting = true;
    }

    if (
      getSObjectType().getDescribe().fields.getMap().containsKey('RecordTypeId')
    ) {
      mthContext = filterContextByRecordTypeId(mthContext);
    }

    this.context = mthContext;
  }

  @TestVisible
  private TriggerContext filterContextByRecordTypeId(
    TriggerContext mthContext
  ) {
    Map<Id, Schema.RecordTypeInfo> recordinfos = getRecordTypeInfosById();
    Integer i = 0;

    while (
      i <
      (mthContext.News != null
        ? mthContext.News.size()
        : mthContext.Olds.size())
    ) {
      SObject object1 = mthContext.News != null
        ? mthContext.News[i]
        : mthContext.Olds[i];
      SObject object2 = mthContext.Olds != null
        ? mthContext.Olds[i]
        : mthContext.News[i];
      String RecordTypeId1 = (String) object1.get('RecordTypeId');
      String RecordTypeId2 = (String) object2.get('RecordTypeId');

      if (
        !recordinfos.containsKey(RecordTypeId1) &&
        !recordinfos.containsKey(RecordTypeId2)
      ) {
        if (mthContext.News != null) {
          if (mthContext.NewsMap != null)
            mthContext.NewsMap.remove(object1.Id);
          mthContext.News.remove(i);
        }
        if (mthContext.Olds != null) {
          if (mthContext.OldsMap != null)
            mthContext.OldsMap.remove(object2.Id);
          mthContext.Olds.remove(i);
        }
      } else {
        i++;
      }
    }

    mthContext.CanRun =
      (mthContext.News != null
        ? mthContext.News.size()
        : mthContext.Olds.size()) > 0;

    return mthContext;
  }

  // increment the loop count
  @TestVisible
  private void addToLoopCount() {
    String handlerName = getHandlerName();
    if (SObjectDomain.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = SObjectDomain.loopCountMap.get(handlerName)
        .increment();
      if (exceeded) {
        Integer max = SObjectDomain.loopCountMap.get(handlerName).max;
        throw new TriggerHandlerException(
          'Maximum loop count of ' +
            String.valueOf(max) +
            ' reached in ' +
            handlerName
        );
      }
    }
  }

  // make sure this trigger should continue to run
  @TestVisible
  private Boolean validateRun() {
    if (!this.isTriggerExecuting || this.context == null) {
      throw new TriggerHandlerException(
        'Trigger handler called outside of Trigger execution'
      );
    }
    if (SObjectDomain.bypassedHandlers.contains(getHandlerName())) {
      return false;
    }
    return true;
  }

  @TestVisible
  private String getHandlerName() {
    return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
  }
  // ***************************************
  // *********** context methods ***********
  // ***************************************
  // context-specific methods for override
  @TestVisible
  protected virtual void onBeforeInsert() {
  }
  @TestVisible
  protected virtual void onBeforeUpdate() {
  }
  @TestVisible
  protected virtual void onBeforeDelete() {
  }
  @TestVisible
  protected virtual void onAfterInsert() {
  }
  @TestVisible
  protected virtual void onAfterUpdate() {
  }
  @TestVisible
  protected virtual void onAfterDelete() {
  }
  @TestVisible
  protected virtual void onAfterUndelete() {
  }

  // ***************************************
  // ************ inner classes ************
  // ***************************************

  // inner class for managing the loop count per handler
  @TestVisible
  private class LoopCount {
    private Integer max;
    private Integer count;

    public LoopCount() {
      this.max = 5;
      this.count = 0;
    }

    public LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }

    public Boolean exceeded() {
      if (this.max < 0)
        return false;
      if (this.count > this.max) {
        return true;
      }
      return false;
    }

    public Integer getMax() {
      return this.max;
    }

    public Integer getCount() {
      return this.count;
    }

    public void setMax(Integer max) {
      this.max = max;
    }
  }

  public class TriggerContext {
    public System.TriggerOperation Operation;
    public List<SObject> News;
    public List<SObject> Olds;
    public Map<Id, SObject> NewsMap;
    public Map<Id, SObject> OldsMap;
    public Boolean CanRun;
  }

  // exception class
  public class TriggerHandlerException extends Exception {
  }
}