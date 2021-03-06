# 두 번째 평가과제: 메모 앱

## 📱 iPhone 8
no. | 내용 | 화면 녹화
------- | ------- | ------- |
1 | 처음 앱 실행 시 Walkthrough 팝업 화면 | ![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 12 56 41](https://user-images.githubusercontent.com/22907483/141408407-3c3a3993-5aa0-4e72-8dd2-ad01abbe1043.gif)  
2 | 하단 TabBarItem을 클릭하여 새 메모 작성 후 완료 버튼 클릭하여 저장 | ![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 12 57 08](https://user-images.githubusercontent.com/22907483/141408417-b4cb1d3a-c026-47a7-9cf3-a274f6df3cf3.gif)
3 | leadingSwipeAction으로 메모 고정 및 고정 해제(5개 제한) | ![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 12 59 29](https://user-images.githubusercontent.com/22907483/141408423-953a2412-01dc-4354-8150-d7c0fdb613de.gif)  
4 | TrailingSwipeAction으로 메모 삭제 | ![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 13 01 13](https://user-images.githubusercontent.com/22907483/141408428-c974a7cb-411a-4e30-a458-13cde00c7f10.gif)    
5 | 검색 기능(검색어 textColor 변경) | ![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 13 02 11](https://user-images.githubusercontent.com/22907483/141408436-b2d8254c-2d4d-4da3-ae37-e30306d2dfcf.gif)   
6 | 작성한 메모 내용 수정 및 내용 공유 | ![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 13 02 37](https://user-images.githubusercontent.com/22907483/141408438-04dd123d-d48f-41f1-99a1-6a1042f228dc.gif)  
7 | 메모 비어있는 경우 해당 메모 삭제 | ![Simulator Screen Recording - iPhone 8 - 2021-11-12 at 13 35 13](https://user-images.githubusercontent.com/22907483/141410255-2edfedb0-eb27-4a0d-83a1-ae48053e962e.gif)
  

## 📱 iPhone 13 Pro Max
no. | 내용 | 화면 녹화
------- | ------- | ------- |
1 | 처음 앱 실행 시 Walkthrough 팝업 화면 | ![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 13 06 10](https://user-images.githubusercontent.com/22907483/141408148-1846e3ed-f342-4d3b-931c-02475292c241.gif)  
2 | 하단 TabBarItem을 클릭하여 새 메모 작성 후 완료 버튼 클릭하여 저장 | ![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 13 06 42](https://user-images.githubusercontent.com/22907483/141408152-f0b8b36a-95b5-4ca2-9ff1-4cb93a9d3c2d.gif)  
3 | leadingSwipeAction으로 메모 고정 및 고정 해제(5개 제한) | ![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 13 08 24](https://user-images.githubusercontent.com/22907483/141408154-9db1cbc1-845f-4489-afec-f3cf5b0552b1.gif)  
4 | TrailingSwipeAction으로 메모 삭제 | ![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 13 08 55](https://user-images.githubusercontent.com/22907483/141408155-faf2a819-5e35-48be-85ee-74522495e9e4.gif)  
5 | 검색 기능(검색어 textColor 변경) | ![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 13 09 21](https://user-images.githubusercontent.com/22907483/141408157-4e08c0d7-1174-4588-814e-bdc88d5be7bd.gif)    
6 | 작성한 메모 내용 수정 및 내용 공유 | ![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 13 09 42](https://user-images.githubusercontent.com/22907483/141408159-bba46c59-63f0-4af1-b797-800072bb5c88.gif)  
7 | 메모 비어있는 경우 해당 메모 삭제 | ![Simulator Screen Recording - iPhone 13 Pro Max - 2021-11-12 at 13 36 47](https://user-images.githubusercontent.com/22907483/141410371-47b5635e-fd16-42cb-99f3-f0f7e2f3c7e7.gif)

## ✔️ 해결하지 못한 부분
- LeadingSwipe로 핀 고정하는 경우, 제한된 수를 넘길 때 뜨는 alert의 "확인" 버튼을 누르면 자동으로 swipe가 다시 slide back 되도록 구현함.
TrailingSwipe로 메모를 삭제하려고 시도하는 경우 뜨는 alert의 "취소" 버튼을 누르는 경우 동일하게 자동으로 slide back 되게 구현하려 했으나 작동하지 않아서 실패 .. 
- TableView style을 코드로 변경하는 방법을 찾지 못해 Storyboard로 구현 ..
