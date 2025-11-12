import SwiftUI

struct HomeFiltersView: View {
  let filters: [DetailingFilter]
  @Binding var selected: DetailingFilter

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: AppStyle.Padding.small16.rawValue) {
        ForEach(filters) { filter in
          FilterChip(
            title: filter.title,
            isSelected: selected == filter,
            action: { selected = filter }
          )
        }
      }
      .padding(.horizontal, AppStyle.Padding.small16.rawValue)
      .padding(.vertical, AppStyle.Padding.small16.rawValue)
      .background(Color.white)
    }
  }
}
