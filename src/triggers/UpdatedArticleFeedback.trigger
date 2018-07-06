/**
 * @author Altimetrik
 * @description
 *    started on 07/05/2018
 *    Trigger on the after update event of an article feedback item
 **/
trigger UpdatedArticleFeedback on Article_Feedback__c (after update) {

 List<FeedComment> commentList = new List<FeedComment>();

  for (Article_Feedback__c af : Trigger.new) {
  	Article_Feedback__c oldAf = Trigger.oldMap.get(af.Id);

		if(oldAf.Article_Feed_Update__c != af.Article_Feed_Update__c) {
	      if(String.isNotBlank(af.Parent_FeedItem__c)) {
	        FeedComment comment = new FeedComment();
    	    comment.FeedItemId = af.Parent_FeedItem__c; //Id of the FeedItem to comment on
    	    comment.CommentBody = af.Article_Feed_Update__c + '\n Article Feedback ' + af.Name + '. \n';
    	    commentList.add(comment);
        }
  	 }
  }

  if(!commentList.isEmpty()) {
    insert commentList;
  }
}