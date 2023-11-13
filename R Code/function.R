# 활용 함수 함수화
### 요약 통계 계산 함수
calculate_summary <- function(data, columns) {
  summary_list <- list()
  for (col in columns) {
    col_name <- ensym(col)  # 컬럼 이름을 평가하여 저장
    summary_df <- data %>% summarise(
      평균=round(mean(!!col_name), 3),
      중앙값=median(!!col_name),
      표준편차=round(sd(!!col_name), 3),
      최대값=max(!!col_name),
      최소값=min(!!col_name),
      사분위수_1=quantile(!!col_name, 0.25),
      사분위수_3=quantile(!!col_name, 0.75)
    )
    summary_list[[col]] <- summary_df
  }
  summary_df <- bind_rows(summary_list, .id = "컬럼")
  return(summary_df)
}

### 막대그래프 도식화 함수
plot_bar <- function(data, x_var, y_var, title, x_label, y_label, reorder) {
    if(reorder){
      ggplot(data, 
             aes(x = reorder({{x_var}}, -{{y_var}}), y = {{y_var}}, fill = {{x_var}}))+
        geom_bar(stat = "identity")+
        labs(title = title, x = x_label, y = y_label)+
        theme_minimal()+
        geom_text(aes(label = {{y_var}}), vjust = -0.5)
      } else {
        ggplot(data, 
               aes(x = reorder({{x_var}}, {{y_var}}), y = {{y_var}}, fill = {{x_var}}))+
          geom_bar(stat = "identity")+
          labs(title = title, x = x_label, y = y_label)+
          theme_minimal()+
          geom_text(aes(label = {{y_var}}), vjust = -0.5)
      }
}

### 파이차트 도식화 함수
plot_pie_chart <- function(data, y_var, fill_var, title){
  ggplot(data, aes(x = '', y = {{y_var}}, fill = {{fill_var}})) +
    geom_bar(stat = 'identity') +
    theme_void() +
    coord_polar('y', start = 0) +
    labs(title = title) +
    geom_text(aes(label = paste0({{y_var}}*100, '%')),
              position = position_stack(vjust = 0.5),
              color = 'white',
              family = 'serif',
              size = 5)
}
