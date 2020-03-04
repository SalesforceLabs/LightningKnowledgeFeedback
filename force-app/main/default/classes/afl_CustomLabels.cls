/**
* @author Altimetrik
* @description
*    started on 21/02/2020
*    Custom labels reference to be included in package
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

            // Feedback setup page
            String setup_page_title = Label.Setup_page_title;
            String hashtag_settings_title = Label.Hashtag_settings_title;
            String save_button = Label.Save_button;
            String setup_picklist_values_title = Label.Setup_picklist_values_title;
            String add_value_to_Feedback_picklist = Label.Add_value_to_Feedback_picklist;
            String add_value_to_Feedback_picklist_placeholder = Label.Add_value_to_Feedback_picklist_placeholder;
            String add_button = Label.Add_button;
            String feedback_reason_picklist = Label.Feedback_reason_picklist;
            String feedback_reason_picklist_explanation = Label.Feedback_reason_picklist_explanation;
            String delete_button = Label.Delete_button;
            String configure_values_to_be_displayed = Label.Configure_values_to_be_displayed;
            String configure_values_helptext = Label.Configure_values_helptext;
            String available_values_label = Label.Available_values_label;
            String selected_positive_values_label = Label.Selected_positive_values_label;
            String selected_negative_values_label = Label.Selected_negative_values_label;
            String picklist_with_semicolon_error = Label.Picklist_with_semicolon_error;
            String picklist_empty_error = Label.Picklist_empty_error;
            String value_exists_error = Label.Value_exists_error;
            String adding_value_error = Label.Adding_value_error;
            String no_hashtag_error = Label.No_hashtag_error;
            String no_hashtag_or_square_bracket_error = Label.No_hashtag_or_square_bracket_error;
            String hashtag_value_updated_message = Label.Hashtag_value_updated_message;
            String update_hashtag_error = Label.Update_hashtag_error;
            String values_updated_message = Label.Values_updated_message;
            String update_values_error = Label.Update_values_error;
            String select_a_value_to_delete_error = Label.Select_a_value_to_delete_error;
            String values_deleted_message = Label.Values_deleted_message;
            String deleting_values_error = Label.Deleting_values_error;

            // Related article component
            String language_Disclaimer = Label.Language_Disclaimer;
            String language_Disclaimer_Helptext = Label.Language_Disclaimer_Helptext;
            String related_Article_Title = Label.Related_Article_Title;
            String view_Article_Button = Label.View_Article_Button;
            String article_was_not_found_error = Label.Article_was_not_found_error;
            String related_article_not_found_error = Label.Related_article_not_found_error;
            String article_Feedback_id_not_found_on_Related_Article_error = Label.Article_Feedback_id_not_found_on_Related_Article_error;
            String related_article_information_retrieval_error = Label.Related_article_information_retrieval_error;
        } catch (Exception e) {
            success = false;
        }

        return success;
    }
}
