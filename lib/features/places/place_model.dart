// ==========================================
// ไฟล์: places_model.dart
// ==========================================

enum PlaceStatus {
  locked,
  active,
  done,
}

class Place {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String longDescription;
  final String hint;
  final String location;
  final String historicalBackground;
  final PlaceStatus status;

  const Place({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.longDescription,
    required this.hint,
    required this.location,
    required this.historicalBackground,
    this.status = PlaceStatus.locked, // ค่าเริ่มต้นให้เป็น locked
  });

  Place copyWith({PlaceStatus? status}) {
    return Place(
      id: id,
      name: name,
      imageUrl: imageUrl,
      description: description,
      longDescription: longDescription,
      hint: hint,
      location: location,
      historicalBackground: historicalBackground,
      status: status ?? this.status,
    );
  }
}

// ชุดข้อมูล Mock Data 
final List<Place> mockPlaces = [
  const Place(
    id: '1',
    name: 'วัดขาวลาด',
    imageUrl: 'https://images.unsplash.com/photo-1548013146-72479768bbaa?q=80&w=800&auto=format&fit=crop',
    description: 'วัดโบราณที่มีความเป็นเอกลักษณ์ของจันทบูร',
    longDescription: 'วัดขาวลาดเป็นวัดโบราณแห่งหนึ่งที่มีความสำคัญทางศาสนาและวัฒนธรรม ตั้งอยู่ริมน้ำจันทบูร มีสถาปัตยกรรมที่สวยงามและเป็นแหล่งท่องเที่ยวทางศาสนา',
    hint: 'ถ่ายรูปให้เห็นอุโบสถหรือหอนาฬิกาของวัด และลายไทยที่สำคัญ',
    location: 'ต้นน้ำ อำเภอเมือง จันทบูร',
    historicalBackground: 'วัดขาวลาดมีประวัติศาสตร์อันยาวนานตั้งแต่สมัยกรุงธนบุรี เป็นสถานที่สำคัญทางพระพุทธศาสนา',
    status: PlaceStatus.active, // ด่านแรกเริ่มที่ Active
  ),
  const Place(
    id: '2',
    name: 'หาดชันโต',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=800&auto=format&fit=crop',
    description: 'หาดท่องเที่ยวชื่อดังของจันทบูร',
    longDescription: 'หาดชันโตเป็นหาดชายทะเลที่มีทรายสีขาว นำเสนอความสวยงามของธรรมชาติริมทะเล พบได้ความสะดวกสบายและแหล่งท่องเที่ยว',
    hint: 'ถ่ายรูปทะเล ม้ายน้ำ หรือหอเก่า เพื่อยืนยันการสำรวจหาด',
    location: 'หาดชันโต อำเภอเมือง จันทบูร',
    historicalBackground: 'หาดชันโตเป็นแหล่งท่องเที่ยวที่พัฒนาจากอุตรุยตรฤษี เดิมเป็นที่ทำเสบียงของชาวบ้าน',
  ),
  const Place(
    id: '3',
    name: 'ตลาดน้ำจันทบูร',
    imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561341?q=80&w=800&auto=format&fit=crop',
    description: 'ตลาดโบราณที่เต็มไปด้วยความเป็นจันทบูร',
    longDescription: 'ตลาดน้ำจันทบูรเป็นตลาดโบราณที่รวบรวมอยู่บนน้ำ มีสินค้าท้องถิ่นและอาหารสตรีทฟู้ด ที่มีชื่อเสียงไปไกลถึงต่างประเทศ',
    hint: 'ถ่ายรูปหลังแถว บ้านเรือ หรือสินค้าโบราณ เพื่อบันทึกความเป็นเอกลักษณ์',
    location: 'ซอย 5 อำเภอเมือง จันทบูร',
    historicalBackground: 'ตลาดน้ำจันทบูรมีอายุมากกว่า 100 ปี เป็นศูนย์กลางการค้าขายในสมัยที่ผ่านมา',
  ),
  const Place(
    id: '4',
    name: 'วิหารโบราณ สมเด็จพระเจ้า',
    imageUrl: 'https://images.unsplash.com/photo-1606214174585-fe31582dc1d8?q=80&w=800&auto=format&fit=crop',
    description: 'วิหารสำคัญเก่าแก่ของจันทบูร',
    longDescription: 'วิหารโบราณสมเด็จพระเจ้า เป็นอาคารศาสนเก่าแก่ที่สะท้อนศิลปะสถาปัตยกรรมไทยยุคสมัยต่างๆ มีคุณค่าทางประวัติศาสตร์สูง',
    hint: 'ถ่ายภาพโครงสร้างแกะสลัก ประตูหน้า หรือรูปปั้นที่เก่าแก่',
    location: 'ใจกลางเมือง อำเภอเมือง จันทบูร',
    historicalBackground: 'อาคารศาสนเก่าแก่นี้มีความสำคัญเป็นเอกสารประวัติศาสตร์ของจันทบูร',
  ),
  const Place(
    id: '5',
    name: 'สวนพืชและสัตว์ป่า',
    imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?q=80&w=800&auto=format&fit=crop',
    description: 'พื้นที่ธรรมชาติยุ้งค้างคาวในชุมชนริมน้ำ',
    longDescription: 'สวนพืชและสัตว์ป่า เป็นแหล่งอนุรักษ์พืชพันธุ์ท้องถิ่นและสัตว์ที่หายาก นำเสนอความสำคัญของนิเวศวิทยาของจันทบูร',
    hint: 'ถ่ายรูปสัตว์โดยธรรมชาติ ต้นไม้โบราณ หรือภูมิทัศน์ของสวน',
    location: 'บ้านไร่ อำเภอเมือง จันทบูร',
    historicalBackground: 'พื้นที่นี้เป็นพื้นที่องค์กรหนึ่งที่เก่าแก่ในการอนุรักษ์ธรรมชาติของจันทบูร',
  ),
  const Place(
    id: '6',
    name: 'หัวหนานศิลปเมือง',
    imageUrl: 'https://images.unsplash.com/photo-1577720643272-265b7a14e16f?q=80&w=800&auto=format&fit=crop',
    description: 'พื้นที่ศิลปะและวัฒนธรรมของจันทบูร',
    longDescription: 'หัวหนานศิลปเมืองเป็นพื้นที่ที่รวบรวมศิลปะและวัฒนธรรมท้องถิ่นของจันทบูร ที่เก่าแก่และน่าสนใจ',
    hint: 'ถ่ายรูปงานศิลปะ แกะสลัก หรือสิ่งที่เป็นเอกลักษณ์เดิมที่ยังคงอยู่',
    location: 'หน้าวัด อำเภอเมือง จันทบูร',
    historicalBackground: 'พื้นที่ศิลปะนี้มีการรวบรวมศิลปกรรมและวัฒนธรรมท้องถิ่นมานานกว่า 50 ปี',
  ),
];