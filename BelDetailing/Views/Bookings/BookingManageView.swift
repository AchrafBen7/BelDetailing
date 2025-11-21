import SwiftUI
import RswiftResources

struct BookingManageSheetView: View {

    let booking: Booking
    let engine: Engine
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var tabBarVisibility: TabBarVisibility
    
    @State private var newDate: Date
    @State private var newTime: String

    private let times = [
        "08:00","09:00","10:00","11:00",
        "12:00","14:00","15:00","16:00","17:00"
    ]

    init(booking: Booking, engine: Engine) {
        self.booking = booking
        self.engine = engine
        _newDate = State(initialValue:
            DateFormatters.isoDateTime(date: booking.date, time: booking.startTime) ?? Date()
        )
        _newTime = State(initialValue: booking.startTime)
    }

    var body: some View {
        VStack(spacing: 24) {

            // ===== HEADER (titel + subtitel) =====
            VStack(spacing: 6) {
                Text(R.string.localizable.bookingManageUpdateTitle())
                    .font(.system(size: 24, weight: .bold))

                Text("\(booking.serviceName) – \(booking.providerName)")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 24)

            // ===== CONTENT =====
            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {

                    // DATE
                    VStack(alignment: .leading, spacing: 14) {
                        Text(R.string.localizable.bookingManageDate())
                            .font(.system(size: 18, weight: .semibold))

                        DatePicker("", selection: $newDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(.orange)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 24)

                    // TIME
                    VStack(alignment: .leading, spacing: 14) {
                        Text(R.string.localizable.bookingManageTime())
                            .font(.system(size: 18, weight: .semibold))

                        Menu {
                            ForEach(times, id: \.self) { time in
                                Button(time) { newTime = time }
                            }
                        } label: {
                            HStack {
                                Text(newTime)
                                    .foregroundColor(.black)

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.25))
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // SUMMARY
                    VStack(alignment: .leading, spacing: 6) {
                        Text(R.string.localizable.bookingManageNewDate())
                            .font(.system(size: 18, weight: .semibold))

                        Text("\(newDate.formatted(date: .long, time: .omitted)) à \(newTime)")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)

                    // SAVE
                    Button { dismiss() } label: {
                        Text(R.string.localizable.bookingManageSave())
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 24)

                    // BACK
                    Button { dismiss() } label: {
                        Text(R.string.localizable.commonBack())
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray.opacity(0.3))
                            )
                    }
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 32)
                }
            }
        }
        .padding(.top, 28)              // 👈 un peu plus d’espace au-dessus du titre
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onAppear { tabBarVisibility.isHidden = true }
        .onDisappear { tabBarVisibility.isHidden = false }
    }
}
