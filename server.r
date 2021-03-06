livy_tm_td <- tidy(livy_tm)

top_terms <- livy_tm_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
top_terms
h3("Narrative Structure and Sentiments in Livy’s Ab Urbe Condita (The History of Rome)")
p("At the dawn of Imperial Rome, Livy sat down to write a comprehensive history of Rome. He was writing in a moment that contained immense friction: Emperor Augustus had just taken sole rule over the Roman Empire, breaking the long tradition of rule by the many which defined the Roman Republic. In many respects, Livy’s work served to argue that Augustus was not the destroyer of traditional Republican society, but its champion and preserver. Livy frame’s Augustus’ rise to power as a return of early Roman ideals and glory, a predestined fate that would save the Empire. To do this, Livy highlights (or entirely fabricates) vignettes in history where a single man is able to rally the people or troops and bring about great victory. Through their frequency, Livy primes his readers to embrace Augustus’ eventual rise. Nevertheless, many modern scholars believe that while Livy’s work can be read as praise of Augustus, there is a strong undercurrent of critique present within the work that serves to question the system of one-man rule.")
p("Could sentiment analysis of Livy’s work enable us to determine Livy’s attitude towards Augustus’ rule and the transition from Roman Republic to the Imperial period? ")
h3("Complications")
p("Unfortunately, less than 25 percent of Livy’s work are extant. We have the earliest part of his work, which covers the period from the founding of Rome in the 6th century B.C. through the wars with Macadonia in 167 B.C. Unfortunately, not even these early works are complete: a section of 10 books, which cover 292 to 264 B.C., are missing from the body of work that we do have. Additionally, there is no direct reference to Augustus himself, which we believe was not introduced until the 134th book. Nevertheless, scholars believe Livy’s attitude towards Augustus can still be detected in his discussion of early Rome, especially it’s founding.  ")
server <- function(input, output) {
  filtered <- reactive({
    if(is.null(input$typeInput)) {
      return(NULL)
    }
    
    LivySentimentCount %>%
      filter(
        Book >= input$Book[1],
        Book <= input$Book[2],
        sentiment %in% input$typeInput
      )
  })
  h3("Sentiment Analysis ")
  p("Negative and positive sentiments are the most common in Livy’s work. Interestingly, the positivity ebbs and flows while the negatively builds but then slowly declines. One explanation for the shape of the positive sentiment is that each peak and valley corresponds to a vignette; the narrative arch starts with a problem but ends with a positive conclusion. Interestingly, trust seems to follow similar peaks and valleys as positivity, but at an overall lower level. Finally, fear is maintained at a constant level. This could be because most of Rome’s early history is tied to attacks and battles.")
  observe({ print(filtered())})
  
  output$coolplot <- renderPlot({
    if (is.null(filtered())) {
      return()
    }
    
    ggplot(filtered(), aes(livy_id, pct, group = sentiment,
                           color = sentiment)) +
      geom_smooth(se = FALSE)+
      ggtitle("Sentiments In Livy")+
      xlab("Book and Chapter")+
      ylab("Percent of Text per Chapter")+
      scale_x_continuous(breaks = break_points$livy_id,
                         labels = break_points$Book)
    
    output$dumbplot <- renderPlot({
      if (is.null(filtered())) {
        return()
      }
      h3("Analysis of Topic Modeling")
      p("By dividing up Livy’s text into five themes, it is clear that Livy spends most of his time focused on economic policy and social wars in history that closely mimic the proposed reforms of Emperor Augustus. For example, the second topic – which contains the key words “people”, “enemy”, “commons”, “tribute”, and “war” – covers the agrarian land reforms of the Grachi brothers. Much like Augustus’ policies, these reforms distanced traditional policy makers (the elite) from the populace. Augustus was able to harness this separation for his own advantage.")
      top_terms %>%
        mutate(term = reorder(term, beta)) %>%
        ggplot(aes(term, beta, fill = factor(topic))) +
        geom_bar(alpha = 0.8, stat = "identity", show.legend = FALSE) +
        facet_wrap(~ topic, scales = "free", ncol = 3) +
        coord_flip()      
    })
  })
}