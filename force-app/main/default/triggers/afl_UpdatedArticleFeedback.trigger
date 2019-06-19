/**
* @author Altimetrik
* @description
*    started on 07/05/2018
*    Trigger on the after update event of an article feedback item
**/
trigger afl_UpdatedArticleFeedback on afl_Article_Feedback__c (after update) {
    List<FeedComment> commentList = new List<FeedComment>();
    List<Id> parentItemsIds = new List<Id>();
    Set<Id> deletedParentsIds = new Set<Id>();

    // Iterate through map to check if feedback article exists
    for (afl_Article_Feedback__c af : Trigger.new) {
        afl_Article_Feedback__c oldAf = Trigger.oldMap.get(af.Id);

        if (oldAf.Article_Feed_Update__c != af.Article_Feed_Update__c) {
            parentItemsIds.add(af.Parent_FeedItem__c);
        }
    }

    // Check with SOQL
    if (parentItemsIds.size() > 0) {
        List<FeedItem> parentFeedList = [
            SELECT Id
            FROM FeedItem
            WHERE Id IN : parentItemsIds AND IsDeleted = true
            ALL ROWS
        ];

        deletedParentsIds = (new Map<Id,FeedItem>(parentFeedList)).keySet();
    }

    for (afl_Article_Feedback__c af : Trigger.new) {
        afl_Article_Feedback__c oldAf = Trigger.oldMap.get(af.Id);

        if (oldAf.Article_Feed_Update__c != af.Article_Feed_Update__c) {
            if (deletedParentsIds.contains(af.Parent_FeedItem__c)) {
                af.Article_Feed_Update__c.addError('An error ocurred trying to update this field.' +
                ' Please check that the post that generated this article feedback exists');
            } else {
                if (String.isNotBlank(af.Parent_FeedItem__c)) {
                    if (af.Parent_FeedItem__c == oldAF.Parent_FeedItem__c) {
                        FeedComment comment = new FeedComment();
                        // Id of the FeedItem to comment on
                        comment.FeedItemId = af.Parent_FeedItem__c;
                        comment.CommentBody = af.Article_Feed_Update__c + '\n Article Feedback ' + af.Name + '. \n';
                        commentList.add(comment);
                    } else {
                        af.Parent_FeedItem__c.addError('An error ocurred. This field cannot be modified');
                    }
                }
            }
        }
    }
    
    if (!commentList.isEmpty()) {
        INSERT commentList;
    }
}