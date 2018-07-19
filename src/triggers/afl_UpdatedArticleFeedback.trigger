/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Trigger on the after update event of an article feedback item
 **/
trigger afl_UpdatedArticleFeedback on afl_Article_Feedback__c (after update) {

 List<FeedComment> commentList = new List<FeedComment>();

  for (afl_Article_Feedback__c af : Trigger.new) {
  	afl_Article_Feedback__c oldAf = Trigger.oldMap.get(af.Id);
		if(oldAf.Article_Feed_Update__c != af.Article_Feed_Update__c) {
          Integer feedCount = [SELECT COUNT() FROM FeedItem WHERE Id =:af.Parent_FeedItem__c AND IsDeleted = true ALL ROWS];
          if(feedCount != 0) {
              af.Article_Feed_Update__c.addError('An error ocurred trying to update this field.' +
              ' Please check that the feed that generated this article feedback exists');
          } else {
    	      if(String.isNotBlank(af.Parent_FeedItem__c)) {
    	        FeedComment comment = new FeedComment();
        	    comment.FeedItemId = af.Parent_FeedItem__c; //Id of the FeedItem to comment on
        	    comment.CommentBody = af.Article_Feed_Update__c + '\n Article Feedback ' + af.Name + '. \n';
        	    commentList.add(comment);
            }
         }
  	 }
  }

  if(!commentList.isEmpty()) {
    insert commentList;
  }
}
