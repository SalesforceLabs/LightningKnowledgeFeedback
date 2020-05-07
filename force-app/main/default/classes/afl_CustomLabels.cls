/**
* @author Altimetrik
* @description
*    started on 21/02/2020
*    Custom labels reference so they are automatically included in package
**/
public with sharing class afl_CustomLabels {
    public static Boolean getLabels() {
        Boolean success = true;
        try {
            // Feedback vote lightning component
            String was_this_article_helpful = Label.Was_this_article_helpful;
            String choose_a_general_reason = Label.Choose_a_general_reason;
            String description = Label.Description;
            String description_placeholder = Label.Description_placeholder;
            String submit_button = Label.Submit_button;
            String no_information_title = Label.No_information_title;
            String appropriate_record_page_message = Label.Appropriate_record_page_message;
            String rate_the_article_toast = Label.Rate_the_article_toast;
            String provide_a_description_toast = Label.Provide_a_description_toast;
            String feedback_saved_toast = Label.Feedback_saved_toast;

            // Feedback setup page
            String setup_page_title = Label.Setup_page_title;
            String hashtag_settings_title = Label.Hashtag_settings_title;
            String save_button = Label.Save_button;
            String no_hashtag_error = Label.No_hashtag_error;
            String no_hashtag_or_square_bracket_error = Label.No_hashtag_or_square_bracket_error;
            String hashtag_value_updated_message = Label.Hashtag_value_updated_message;
            String update_hashtag_error = Label.Update_hashtag_error;
            String hashtag_helptext = Label.Hashtag_helptext;

            // Article Feedback standard record page
            String article_Feedback_creation_alert = Label.Article_Feedback_creation_alert;
            
            // Related article component
            String language_Disclaimer = Label.Language_Disclaimer;
            String language_Disclaimer_Helptext = Label.Language_Disclaimer_Helptext;
            String related_Article_Title = Label.Related_Article_Title;
            String view_Article_Button = Label.View_Article_Button;
            String article_was_not_found_error = Label.Article_was_not_found_error;
            String the_related_article_could_not_be_found = Label.The_related_article_could_not_be_found;
            String related_article_not_found_error = Label.Related_article_not_found_error;
            String article_Feedback_id_not_found_on_Related_Article_error = Label.Article_Feedback_id_not_found_on_Related_Article_error;
            String related_article_information_retrieval_error = Label.Related_article_information_retrieval_error;
        } catch (Exception e) {
            success = false;
        }

        return success;
    }
}
