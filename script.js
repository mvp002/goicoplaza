const rooms = [
  {
    id: 1,
    name: 'Sunset Lounge',
    type: 'Meeting Room',
    capacity: 8,
    price: 120,
    status: 'available',
    description: 'Perfect for client meetings and private consultations.'
  },
  {
    id: 2,
    name: 'Cedar Suite',
    type: 'VIP Room',
    capacity: 12,
    price: 180,
    status: 'booked',
    description: 'A premium room designed for executive conversations.'
  },
  {
    id: 3,
    name: 'Harbor Hall',
    type: 'Event Space',
    capacity: 25,
    price: 260,
    status: 'available',
    description: 'A broad event room for launches, workshops, and gatherings.'
  },
  {
    id: 4,
    name: 'Bloom Room',
    type: 'Private Room',
    capacity: 6,
    price: 95,
    status: 'available',
    description: 'A calm and intimate space for focused work sessions.'
  },
  {
    id: 5,
    name: 'Skyline Studio',
    type: 'Conference Room',
    capacity: 16,
    price: 210,
    status: 'booked',
    description: 'A polished conference area for presentations and team planning.'
  },
  {
    id: 6,
    name: 'Grand Terrace',
    type: 'Event Venue',
    capacity: 40,
    price: 340,
    status: 'available',
    description: 'A larger venue suited for receptions and community events.'
  }
];

const roomGrid = document.getElementById('roomGrid');
const roomSelect = document.getElementById('roomSelect');
const quickRoomList = document.getElementById('quickRoomList');
const bookingForm = document.getElementById('bookingForm');
const availableOnlyToggle = document.getElementById('availableOnlyToggle');
const showAvailableBtn = document.getElementById('showAvailableBtn');
const toastContainer = document.getElementById('toastContainer');

function getAvailableRooms() {
  return rooms.filter((room) => room.status === 'available');
}

function renderRoomCards(showOnlyAvailable = false) {
  const visibleRooms = showOnlyAvailable ? getAvailableRooms() : rooms;

  roomGrid.innerHTML = visibleRooms
    .map(
      (room) => `
        <div class="col-md-6 col-xl-4">
          <div class="room-card">
            <div class="room-image"></div>
            <div class="card-body">
              <div class="d-flex justify-content-between align-items-center gap-3">
                <h3>${room.name}</h3>
                <span class="status-pill ${room.status}">${room.status === 'available' ? 'Available' : 'Booked'}</span>
              </div>
              <p class="text-muted mb-2">${room.type}</p>
              <p>${room.description}</p>
              <div class="room-meta">
                <span>👥 ${room.capacity} guests</span>
                <span>🕒 Flexible</span>
              </div>
              <div class="d-flex justify-content-between align-items-center mt-3">
                <div class="price">$${room.price}</div>
                <div class="small text-muted">/ session</div>
              </div>
            </div>
            <div class="card-footer d-grid">
              <button
                class="btn ${room.status === 'available' ? 'btn-primary' : 'btn-outline-secondary'}"
                type="button"
                data-room-id="${room.id}"
                ${room.status === 'booked' ? 'disabled' : ''}
              >
                ${room.status === 'available' ? 'Book now' : 'Unavailable'}
              </button>
            </div>
          </div>
        </div>
      `
    )
    .join('');

  document.querySelectorAll('[data-room-id]').forEach((button) => {
    button.addEventListener('click', () => {
      const roomId = Number(button.dataset.roomId);
      const room = rooms.find((item) => item.id === roomId);
      if (room) {
        roomSelect.value = room.id;
        document.getElementById('booking').scrollIntoView({ behavior: 'smooth' });
        showToast(`${room.name} selected for booking.`);
      }
    });
  });
}

function renderQuickRooms() {
  const available = getAvailableRooms();
  quickRoomList.innerHTML = available
    .slice(0, 4)
    .map(
      (room) => `
        <li class="quick-room-item">
          <span>${room.name}</span>
          <span class="status-pill available">Open</span>
        </li>
      `
    )
    .join('');
}

function renderRoomOptions() {
  roomSelect.innerHTML = rooms
    .map(
      (room) => `
        <option value="${room.id}" ${room.status === 'booked' ? 'disabled' : ''}>
          ${room.name} ${room.status === 'booked' ? '(Booked)' : ''}
        </option>
      `
    )
    .join('');

  const firstAvailable = rooms.find((room) => room.status === 'available');
  if (firstAvailable) {
    roomSelect.value = String(firstAvailable.id);
  }
}

function showToast(message) {
  const toastEl = document.createElement('div');
  toastEl.className = 'toast align-items-center text-bg-dark border-0 show';
  toastEl.setAttribute('role', 'alert');
  toastEl.setAttribute('aria-live', 'assertive');
  toastEl.innerHTML = `
    <div class="d-flex">
      <div class="toast-body">${message}</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" aria-label="Close"></button>
    </div>
  `;

  toastContainer.appendChild(toastEl);

  const closeBtn = toastEl.querySelector('.btn-close');
  closeBtn.addEventListener('click', () => toastEl.remove());

  setTimeout(() => toastEl.remove(), 2500);
}

function handleBookingSubmit(event) {
  event.preventDefault();

  const name = document.getElementById('clientName').value.trim();
  const phone = document.getElementById('phone').value.trim();
  const roomId = Number(roomSelect.value);
  const date = document.getElementById('date').value;
  const time = document.getElementById('time').value;
  const guests = Number(document.getElementById('guests').value);

  const selectedRoom = rooms.find((room) => room.id === roomId);
  if (!selectedRoom || selectedRoom.status === 'booked') {
    showToast('That room is already booked. Please choose another one.');
    return;
  }

  if (!name || !phone || !date || !time || !guests) {
    showToast('Please complete all booking details before confirming.');
    return;
  }

  selectedRoom.status = 'booked';
  bookingForm.reset();
  renderRoomCards(availableOnlyToggle.checked);
  renderRoomOptions();
  renderQuickRooms();
  showToast(`Booking confirmed for ${selectedRoom.name} on ${date} at ${time}.`);
}

availableOnlyToggle.addEventListener('change', () => {
  renderRoomCards(availableOnlyToggle.checked);
});

showAvailableBtn.addEventListener('click', () => {
  availableOnlyToggle.checked = true;
  renderRoomCards(true);
  document.getElementById('rooms').scrollIntoView({ behavior: 'smooth' });
  showToast('Showing only empty rooms.');
});

bookingForm.addEventListener('submit', handleBookingSubmit);

renderRoomCards(false);
renderRoomOptions();
renderQuickRooms();
