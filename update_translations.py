# -*- coding: utf-8 -*-
import re

# Read app_translations
with open(r'e:\rimnam_app\lib\core\localization\app_translations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# The translations to append for each language
th_places = """
      'place_1_name': 'วัดโบสถ์เมือง',
      'place_1_desc': 'วัดเก่าแก่คู่เมืองจันทบุรี โดดเด่นด้วยเจดีย์ศิลปะอยุธยาตอนปลาย',
      'place_1_long_desc': '''วัดโบสถ์เมือง เป็นวัดราษฎร์เก่าแก่ใจกลางเมืองจันทบุรี ตั้งอยู่บนเนินสูงติดแม่น้ำจันทบุรี สันนิษฐานว่าสร้างขึ้นในสมัยอยุธยาตอนปลาย และได้รับการปฏิสังขรณ์เรื่อยมาจนเป็นศูนย์รวมจิตใจของชาวจันทบุรี\\n\\n📜 ประวัติและความเป็นมา\\n• จุดเริ่มต้น: เดิมสร้างขึ้นในสมัยอยุธยา สังเกตได้จากหลักฐานใบเสมาหินทรายขาวและเจดีย์ทรงระฆัง\\n• การบูรณะครั้งสำคัญ: มีการสร้างอุโบสถขึ้นใหม่เมื่อปี พ.ศ. 2330 และได้รับพระราชทานวิสุงคามสีมาในปี พ.ศ. 2335\\n• ยุคประพาสต้น: มีความสำคัญทางประวัติศาสตร์ โดยรัชกาลที่ 5 ทรงเคยกล่าวถึงในคราวเสด็จประพาสต้นเมืองจันทบุรี\\n\\n🏛️ สิ่งที่น่าสนใจภายในวัด\\n• พระประธานและเจดีย์: ประดิษฐานพระประธานประจำอุโบสถ และมีพระเจดีย์โบราณที่เชื่อว่าบรรจุพระบรมสารีริกธาตุ\\n• สถาปัตยกรรมเก่าแก่: ตัวอุโบสถผสมผสานศิลปะไทยและจีน ได้รับการอนุรักษ์ไว้อย่างดี\\n• สถานที่ตั้ง: ตั้งอยู่บนถนนเบญจมราชูทิศ เชื่อมต่อกับชุมชนริมน้ำจันทบูร''',
      'place_1_hint': 'ถ่ายภาพเจดีย์ทรงระฆังคว่ำ หรือลวดลายกระเบื้องเคลือบที่ประดับบนหน้าบันอุโบสถ',
      'place_1_loc': 'ถนนสุขาภิบาล ชุมชนริมน้ำจันทบูร อ.เมือง จ.จันทบุรี',
      'place_1_history': 'สันนิษฐานว่าสร้างขึ้นตั้งแต่สมัยอยุธยาตอนปลาย (ประมาณปี พ.ศ. 2395) เป็นวัดที่เก่าแก่ที่สุดแห่งหนึ่งของเมืองจันทบุรี เคยผ่านการบูรณะมาหลายยุคหลายสมัย ทำให้เราได้เห็นร่องรอยทางประวัติศาสตร์ที่ซ้อนทับกันอยู่ เป็นทั้งสถานปฏิบัติธรรมและศูนย์กลางชุมชนมาอย่างยาวนาน',
      
      'place_2_name': 'บ้านหลวงราชไมตรี',
      'place_2_desc': 'บ้านไม้สักทองอายุกว่า 150 ปี ของ "บิดาแห่งยางพาราตะวันออก"',
      'place_2_long_desc': '''บ้านหลวงราชไมตรี (Historic Inn) เป็นบ้านพักประวัติศาสตร์อายุกว่า 150 ปี สร้างขึ้นเพื่อรวบรวมเรื่องราวของหลวงราชไมตรี "บิดาแห่งยางพาราภาคตะวันออก" ปัจจุบันได้รับการบูรณะเป็นที่พักเชิงอนุรักษ์\\n\\n📜 ประวัติและความเป็นมา\\n• หลวงราชไมตรี: อดีตคหบดีผู้ริเริ่มนำพันธุ์ยางพารามาปลูกในภาคตะวันออกจนสร้างเศรษฐกิจที่เจริญรุ่งเรือง\\n• การอนุรักษ์: ชุมชนร่วมกันระดมทุนในรูปแบบวิสาหกิจเพื่อสังคมเพื่อปรับปรุงบ้านให้เป็นที่พักและพิพิธภัณฑ์\\n• รางวัลระดับสากล: ได้รับรางวัล Award of Merit จาก UNESCO ในปี พ.ศ. 2558 ด้านการอนุรักษ์มรดกทางวัฒนธรรม\\n\\n🏛️ สิ่งที่น่าสนใจภายในสถานที่\\n• สถาปัตยกรรมชิโน-โปรตุกีส: ตัวบ้านผสมผสานศิลปะตะวันตกและไม้สักทองของไทยอย่างลงตัว\\n• พิพิธภัณฑ์ขนาดย่อม: ชั้นล่างจัดแสดงเครื่องใช้ส่วนตัวและสมุดบัญชีโบราณของหลวงราชไมตรี\\n• บรรยากาศริมน้ำ: ระเบียงด้านหลังติดกับแม่น้ำจันทบุรี ให้ความรู้สึกย้อนยุคและสงบเงียบ''',
      'place_2_hint': 'ถ่ายภาพระเบียงไม้ฉลุลายฝั่งริมแม่น้ำ หรือข้าวของเครื่องใช้โบราณในห้องจัดแสดง',
      'place_2_loc': '252 ถนนสุขาภิบาล ชุมชนริมน้ำจันทบูร อ.เมือง จ.จันทบุรี',
      'place_2_history': 'หลวงราชไมตรี (ปูม ปุณศรี) เป็นบุคคลสำคัญผู้ริเริ่มนำกล้า "ยางพารา" จากมาเลเซียมาทดลองปลูกในภาคตะวันออกเป็นครั้งแรก จนกลายเป็นพืชเศรษฐกิจสำคัญ สถานที่แห่งนี้ได้รับการยกย่องและรับรางวัล "Award of Merit" จาก UNESCO ในปี พ.ศ. 2558 ด้านการอนุรักษ์มรดกทางวัฒนธรรมในภูมิภาคเอเชียแปซิฟิก',

      'place_3_name': 'ศาลเจ้าตั้วเล่าเอี๊ย',
      'place_3_desc': 'ศาลเจ้าจีนโบราณ ศูนย์รวมศรัทธาของชาวไทยเชื้อสายจีนริมน้ำ',
      'place_3_long_desc': '''ศาลเจ้าตั้วเล่าเอี๊ย หรือที่ชาวบ้านเรียกว่า ศาลเจ้าพ่อเสือ เป็นศาสนสถานสถาปัตยกรรมแบบจีนตอนใต้ที่เก่าแก่ที่สุดแห่งหนึ่งในย่านชุมชนริมน้ำจันทบูร เป็นศูนย์รวมศรัทธาของชาวไทยเชื้อสายจีนในพื้นที่\\n\\n📜 ประวัติและความเป็นมา\\n• การก่อตั้ง: สร้างขึ้นโดยกลุ่มพ่อค้าชาวจีนที่ล่องเรือสำเภามาค้าขายและตั้งถิ่นฐานเมื่อกว่า 150 ปีก่อน\\n• ศูนย์รวมจิตใจ: เป็นสถานที่ยึดเหนี่ยวจิตใจและศูนย์กลางการพบปะของชาวจีนฮกเกี้ยนและแต้จิ๋ว\\n• เทศกาลสำคัญ: เป็นสถานที่หลักในการจัดงานประเพณีสำคัญๆ เช่น ตรุษจีน สารทจีน และงานเทกระจาดประจำปี\\n\\n🏛️ สิ่งที่น่าสนใจภายในศาลเจ้า\\n• องค์ตั้วเล่าเอี๊ย: องค์เทพประธานที่เป็นที่เคารพสักการะ ขอพรเรื่องการค้าขายและความแคล้วคลาด\\n• สถาปัตยกรรมล้ำค่า: หลังคากระเบื้องลอนประดับด้วยมังกรคู่ชูไข่มุกตามคติความเชื่อชาวจีน\\n• ศิลปะโบราณ: มีงานไม้แกะสลักปิดทองที่ละเอียดอ่อนและภาพจิตรกรรมฝาผนังดั้งเดิม''',
      'place_3_hint': 'ถ่ายภาพลวดลายมังกรบนตระค้อหลังคา หรือป้ายอักษรจีนโบราณที่หน้าประตู',
      'place_3_loc': 'ถนนสุขาภิบาล ชุมชนริมน้ำจันทบูร อ.เมือง จ.จันทบุรี',
      'place_3_history': 'สร้างขึ้นโดยกลุ่มพ่อค้าชาวจีนที่ล่องเรือสำเภามาค้าขายและตั้งถิ่นฐานริมแม่น้ำจันทบุรีเมื่อกว่า 150 ปีก่อน ศาลเจ้าแห่งนี้เป็นเครื่องยืนยันถึงความเจริญรุ่งเรืองทางการค้าในอดีต และเป็นศูนย์กลางในการจัดงานเทศกาลสำคัญๆ ของชุมชน เช่น ตรุษจีน และงานเทกระจาด',

      'place_4_name': 'โรงเจเทียงเซ็งตึ้ง',
      'place_4_desc': 'โรงเจแห่งแรกของเมืองจันท์ ศูนย์กลางเทศกาลกินเจ',
      'place_4_long_desc': '''โรงเจเทียงเซ็งตึ้ง เป็นสถานธรรมและโรงเจแห่งแรกของเมืองจันทบุรี สร้างขึ้นตั้งแต่สมัยรัชกาลที่ 5 โดดเด่นด้วยศิลปะจีนโบราณที่ยังคงอนุรักษ์ไว้อย่างสมบูรณ์แบบ\\n\\n📜 ประวัติและความเป็นมา\\n• จุดเริ่มต้น: สร้างโดยชาวจีนอพยพเพื่อเป็นที่ประกอบพิธีกรรมทางศาสนาและถือศีลกินเจ\\n• อายุเก่าแก่: มีประวัติศาสตร์ยาวนานกว่า 100 ปี คู่กับย่านการค้าริมน้ำจันทบูร\\n• ศูนย์กลางประเพณีกินเจ: เป็นหัวใจสำคัญของเทศกาลถือศีลกินเจของชาวจันทบุรีตั้งแต่อดีตจนถึงปัจจุบัน\\n\\n🏛️ สิ่งที่น่าสนใจภายในสถานที่\\n• องค์กิ้วอ๊วงฮุกโจ้ว: ประดิษฐานเทพเจ้าและพระโพธิสัตว์กวนอิมเป็นที่เคารพสักการะ\\n• งานปูนปั้นประดับกระเบื้อง: โดดเด่นด้วยศิลปะการตัดเศษชามกระเบื้องสีมาประดับตกแต่งเป็นลวดลายงดงาม\\n• สถาปัตยกรรมดั้งเดิม: อาคารไม้ผสมปูนแบบสถาปัตยกรรมจีนตอนใต้ที่หาชมได้ยากในปัจจุบัน''',
      'place_4_hint': 'ถ่ายภาพงานปูนปั้นประดับกระเบื้องสีบริเวณเสา หรือแท่นบูชาพระแม่กวนอิมด้านใน',
      'place_4_loc': 'ถนนสุขาภิบาล ชุมชนริมน้ำจันทบูร อ.เมือง จ.จันทบุรี',
      'place_4_history': 'เป็นโรงเจที่เก่าแก่ที่สุดในจังหวัดจันทบุรี สร้างขึ้นในสมัยรัชกาลที่ 5 เพื่อเป็นที่ยึดเหนี่ยวจิตใจของชาวจีนแต้จิ๋วและฮกเกี้ยนในชุมชน แสดงให้เห็นถึงการสืบทอดประเพณีการกินเจที่เคร่งครัดและยาวนานกว่าหนึ่งศตวรรษ',

      'place_5_name': 'อาสนวิหารพระนางมารีอาปฏิสนธินิรมล',
      'place_5_desc': 'โบสถ์คาทอลิกสไตล์โกธิกที่ใหญ่และสวยงามที่สุดในไทย',
      'place_5_long_desc': '''อาสนวิหารพระนางมารีอาปฏิสนธินิรมล เป็นโบสถ์คาทอลิกสไตล์โกธิกที่สวยงามและใหญ่ที่สุดในประเทศไทย ถือเป็นแลนด์มาร์คสำคัญที่อยู่คู่ชุมชนจันทบูรมายาวนาน\\n\\n📜 ประวัติและความเป็นมา\\n• การอพยพของชาวญวน: เริ่มต้นจากการตั้งถิ่นฐานของชาวญวนคาทอลิกที่หนีภัยทางศาสนามากว่า 300 ปีก่อน\\n• การก่อสร้าง: โบสถ์หลังปัจจุบันเป็นหลังที่ 5 สร้างขึ้นในปี พ.ศ. 2449 โดยคุณพ่อเปอติเยต์ ใช้เวลาสร้างนานถึง 10 ปี\\n• เหตุการณ์สำคัญ: หอคอยยอดแหลมเคยถูกรื้อออกในสมัยสงครามโลกครั้งที่ 2 เพื่อไม่ให้เป็นเป้าทิ้งระเบิด และนำกลับมาติดใหม่ในปี 2552\\n\\n🏛️ สิ่งที่น่าสนใจภายในอาสนวิหาร\\n• องค์พระแม่มารีอาประดับพลอย: องค์พระรูปประดับด้วยอัญมณีกว่า 200,000 เม็ด น้ำหนักรวมกว่า 2 หมื่นกะรัต\\n• กระจกสี (Stained Glass): หน้าต่างกระจกสีลวดลายนักบุญที่งดงาม สั่งตรงมาจากประเทศฝรั่งเศส\\n• สถาปัตยกรรมโกธิก: การออกแบบเพดานโค้งสูงและยอดแหลมที่วิจิตรตระการตาแบบตะวันตก''',
      'place_5_hint': 'ถ่ายภาพกระจกสี (Stained glass) ภายในโบสถ์ หรือองค์พระแม่มารีประดับพลอย',
      'place_5_loc': '110 ซอย 1 หมู่ 10 ต.จันทนิมิต อ.เมือง จ.จันทบุรี (ข้ามสะพานนิรมลจากฝั่งชุมชนริมน้ำ)',
      'place_5_history': 'กลุ่มชาวญวนคาทอลิกที่ลี้ภัยทางศาสนามาตั้งถิ่นฐานเป็นผู้ริเริ่มสร้างโบสถ์แห่งแรกเมื่อ 300 ปีก่อน (พ.ศ. 2254) ส่วนอาคารปัจจุบันเป็นหลังที่ 5 สร้างขึ้นในปี พ.ศ. 2449 (สมัย ร.5) ใช้เวลาสร้างถึง 10 ปี หอคอยเคยถูกถอดออกในช่วงสงครามโลกครั้งที่ 2 เพื่อไม่ให้เป็นเป้าโจมตีทางอากาศ และเพิ่งนำกลับมาติดตั้งใหม่ในปี พ.ศ. 2552',

      'place_6_name': 'ศูนย์เรียนรู้ประจำชุมชนริมน้ำจันทบูร บ้านเลขที่ 69',
      'place_6_desc': 'พิพิธภัณฑ์มีชีวิต แหล่งรวบรวมความทรงจำของชาวจันทบูร',
      'place_6_long_desc': '''ศูนย์เรียนรู้ประจำชุมชนริมน้ำจันทบูร (บ้านเลขที่ 69) เดิมเป็นบ้านของขุนอนุสรสมบัติ ปัจจุบันทำหน้าที่เป็นพิพิธภัณฑ์มีชีวิตที่บอกเล่าเรื่องราวความทรงจำของย่านการค้าเก่าแห่งนี้\\n\\n📜 ประวัติและความเป็นมา\\n• บ้านขุนอนุสรสมบัติ: อดีตคหบดีผู้มีบทบาทสำคัญในชุมชน ตัวบ้านจึงสะท้อนถึงความรุ่งเรืองในอดีต\\n• การอุทิศให้ชุมชน: ทายาทได้มอบบ้านหลังนี้ให้เป็นสมบัติของชุมชนเพื่อใช้เป็นแหล่งเรียนรู้\\n• จุดเริ่มต้นการอนุรักษ์: เป็นจุดประกายสำคัญให้เกิดการอนุรักษ์และฟื้นฟูชุมชนริมน้ำจันทบูรให้กลับมามีชีวิตชีวาอีกครั้ง\\n\\n🏛️ สิ่งที่น่าสนใจภายในศูนย์เรียนรู้\\n• นิทรรศการประวัติศาสตร์: รวบรวมภาพถ่ายเหตุการณ์สำคัญ แผนที่โบราณ และข้าวของเครื่องใช้ในอดีต\\n• โมเดลจำลองชุมชน: จัดแสดงโมเดลสามมิติของย่านริมน้ำและสถาปัตยกรรมอาคารต่างๆ ในชุมชน\\n• สถาปัตยกรรมผสมผสาน: ตัวบ้านโดดเด่นด้วยประตูบานเฟี้ยมและช่องลมฉลุลาย ผสมผสานศิลปะไทยและฝรั่งเศส''',
      'place_6_hint': 'ถ่ายภาพโมเดลจำลองชุมชน หรือช่องลมไม้ฉลุลายเหนือประตูบ้าน',
      'place_6_loc': '69 ถนนสุขาภิบาล ชุมชนริมน้ำจันทบูร อ.เมือง จ.จันทบุรี',
      'place_6_history': 'ขุนอนุสรสมบัติ เป็นผู้มีบทบาทสำคัญในชุมชน ต่อมาทายาทได้มอบบ้านหลังนี้ให้ชุมชนดูแล และสถาบันอาศรมศิลป์ได้เข้ามาช่วยบูรณะจนกลายเป็น "ศูนย์เรียนรู้" เพื่อให้คนรุ่นหลังและนักท่องเที่ยวได้มาศึกษา ถือเป็นจุดเริ่มต้นของกระแสการอนุรักษ์ชุมชนริมน้ำจันทบูรจนกลับมามีชีวิตชีวาอีกครั้ง',
"""

zh_places = """
      'place_1_name': '尖竹汶古寺 (Wat Bot Mueang)',
      'place_1_desc': '尖竹汶府历史悠久的寺庙，以阿瑜陀耶晚期的钟形佛塔而闻名',
      'place_1_long_desc': '''尖竹汶古寺是位于尖竹汶市中心的一座历史悠久的寺庙，坐落于尖竹汶河畔的高地上。据推测建于阿瑜陀耶晚期，历经多次修缮，至今仍是当地居民的精神寄托。\\n\\n📜 历史与渊源\\n• 起源：建于阿瑜陀耶时期，从白砂岩结界石和钟形佛塔可见一斑。\\n• 重要修缮：记录显示，1787年重建了主殿，并于1792年获得皇家赐予的结界地。\\n• 国王出巡：拉玛五世国王在巡视尖竹汶府时曾提及此寺庙，具有重要历史意义。\\n\\n🏛️ 寺内景点\\n• 主佛像与佛塔：主殿内供奉着主佛像，还有一座被认为装有佛骨舍利的古老佛塔。\\n• 古老建筑：主殿融合了泰式与中式艺术风格，保存完好。\\n• 位置：位于本差玛拉朱提路，连接着尖竹汶河畔社区。''',
      'place_1_hint': '拍摄钟形佛塔或主殿山墙上的彩绘瓷砖图案',
      'place_1_loc': '尖竹汶府直辖县 尖竹汶河畔社区 Sukhaphiban路',
      'place_1_history': '据推测建于阿瑜陀耶晚期（约1852年），是尖竹汶府最古老的寺庙之一。历经多个时代的修缮，层层历史印记交叠，长期以来一直是当地的宗教与社区中心。',

      'place_2_name': '龙拉贾麦特里故居',
      'place_2_desc': '拥有150年历史的金柚木房屋，属于“东方橡胶之父”',
      'place_2_long_desc': '''龙拉贾麦特里故居（Historic Inn）是一座拥有150年历史的古宅，旨在讲述“东方橡胶之父”龙拉贾麦特里的故事。目前已被修缮为一座精品遗产民宿。\\n\\n📜 历史与渊源\\n• 龙拉贾麦特里：这位前富商率先将橡胶引进东部地区种植，从而创造了繁荣的经济。\\n• 保护工作：社区通过社会企业的形式筹集资金，将这栋房屋改造为民宿和博物馆。\\n• 国际认可：2015年荣获联合国教科文组织（UNESCO）亚太区文化遗产保护奖。\\n\\n🏛️ 景点特色\\n• 中葡建筑风格：建筑完美结合了西方设计与泰国金柚木工艺。\\n• 迷你博物馆：一楼展示了龙拉贾麦特里的个人物品和旧账本。\\n• 滨河氛围：后阳台紧邻尖竹汶河，给人一种宁静复古的感觉。''',
      'place_2_hint': '拍摄河畔的雕花木阳台或展览室内的古老文物',
      'place_2_loc': '尖竹汶府直辖县 尖竹汶河畔社区 Sukhaphiban路 252号',
      'place_2_history': '龙拉贾麦特里（Pum Punsri）是一位重要人物，他首次将橡胶树苗从马来西亚引进东部地区进行试种，使其成为重要的经济作物。该地点在2015年获得了联合国教科文组织的“文化遗产保护奖”。',

      'place_3_name': '大老爷神庙',
      'place_3_desc': '古老的中国神庙，河畔泰华裔的信仰中心',
      'place_3_long_desc': '''大老爷神庙，当地人也称为“玄天上帝庙”，是尖竹汶河畔社区最古老的华南风格神庙之一，也是当地泰华裔的信仰中心。\\n\\n📜 历史与渊源\\n• 建立：150多年前，乘帆船前来经商并定居的中国商人建立了这座神庙。\\n• 精神中心：它是福建和潮州华人的精神寄托和聚会场所。\\n• 重要节日：是春节、中元节等重要年度传统节日的主要举办地。\\n\\n🏛️ 庙内特色\\n• 大老爷神像：受人尊敬的主神，人们祈求生意兴隆、平安顺遂。\\n• 珍贵建筑：波浪形瓦屋顶装饰有双龙戏珠，体现了中国传统信仰。\\n• 古老艺术：拥有精细的镀金木雕和传统的壁画。''',
      'place_3_hint': '拍摄屋顶上的双龙图案或门前的古老中文字匾额',
      'place_3_loc': '尖竹汶府直辖县 尖竹汶河畔社区 Sukhaphiban路',
      'place_3_history': '由150多年前乘帆船前来尖竹汶河畔经商和定居的中国商人建造。这座神庙见证了昔日商业的繁荣，也是社区举办春节和盂兰盆节等重要节日的中心。',

      'place_4_name': '天圣堂斋堂',
      'place_4_desc': '尖竹汶府第一座斋堂，九皇斋节的中心',
      'place_4_long_desc': '''天圣堂斋堂是尖竹汶府第一座修行场所和斋堂。建于拉玛五世时期，以其保存完好的古老中国艺术而闻名。\\n\\n📜 历史与渊源\\n• 起源：由中国移民建造，用于举行宗教仪式和持戒吃素。\\n• 历史悠久：拥有100多年的历史，与尖竹汶河畔商业区相伴。\\n• 斋节中心：从古至今一直是尖竹汶府九皇斋节的核心。\\n\\n🏛️ 场所特色\\n• 九皇佛祖：供奉着九皇佛祖和观音菩萨，供人膜拜。\\n• 碎瓷拼贴艺术：以切割彩色瓷碗碎片装饰成精美图案的艺术而闻名。\\n• 传统建筑：如今罕见的华南木石结构混合建筑。''',
      'place_4_hint': '拍摄柱子上的彩色碎瓷拼贴艺术或内部的观音神台',
      'place_4_loc': '尖竹汶府直辖县 尖竹汶河畔社区 Sukhaphiban路',
      'place_4_history': '这是尖竹汶府最古老的斋堂，建于拉玛五世时期，是社区内潮州和福建华人的精神支柱，体现了传承一个多世纪的严格持斋习俗。',

      'place_5_name': '圣母无原罪主教座堂',
      'place_5_desc': '泰国最大、最美的哥特式天主教堂',
      'place_5_long_desc': '''圣母无原罪主教座堂是泰国最大、最美丽的哥特式天主教堂。它是长期以来与尖竹汶社区相伴的重要地标。\\n\\n📜 历史与渊源\\n• 越南人迁徙：始于300多年前逃避宗教迫害的越南天主教徒的定居。\\n• 建设：目前的第五代教堂建于1906年，由Petit神父主持，历时10年建成。\\n• 重要事件：二战期间为了避免成为轰炸目标，尖塔曾被拆除，并于2009年重新安装。\\n\\n🏛️ 教堂特色\\n• 镶钻圣母像：圣像上镶嵌了超过20万颗宝石，总重超过2万克拉。\\n• 彩色玻璃（Stained Glass）：精美的圣人图案彩色玻璃窗，直接从法国进口。\\n• 哥特式建筑：宏伟壮观的西方高拱顶和尖塔设计。''',
      'place_5_hint': '拍摄教堂内的彩色玻璃窗或镶满宝石的圣母像',
      'place_5_loc': '尖竹汶府直辖县 尖竹汶镇 10村 1巷 110号（从河畔社区过圣母桥即可到达）',
      'place_5_history': '因宗教原因避难的越南天主教徒于300年前（1711年）建立了第一座教堂。目前的建筑是第五代，建于1906年（拉玛五世时期），历时10年。尖塔曾在二战期间被拆除以免成为空袭目标，直到2009年才重新安装。',

      'place_6_name': '尖竹汶河畔社区学习中心 (69号)',
      'place_6_desc': '一座活生生的博物馆，收集了尖竹汶居民的回忆',
      'place_6_long_desc': '''尖竹汶河畔社区学习中心（69号门牌）原为Khun Anusorn Sombat的住所。如今，它作为一座“活着的博物馆”，讲述着这个古老商业街区的记忆和故事。\\n\\n📜 历史与渊源\\n• Khun Anusorn Sombat故居：前富商在社区中发挥了重要作用，这栋房屋反映了昔日的繁荣。\\n• 献给社区：后代将这栋房屋捐赠给社区作为学习中心。\\n• 保护的起点：它是激发保护和复兴尖竹汶河畔社区，使其重新焕发生机的重要契机。\\n\\n🏛️ 中心特色\\n• 历史展览：收集了重要事件的照片、古地图和昔日的日常用品。\\n• 社区微缩模型：展示了河畔区域和社区内各种建筑的3D模型。\\n• 混合建筑风格：该房屋以其折叠门和雕花通风口为特色，融合了泰式和法式艺术。''',
      'place_6_hint': '拍摄社区微缩模型或房屋门上方的雕花木通风口',
      'place_6_loc': '尖竹汶府直辖县 尖竹汶河畔社区 Sukhaphiban路 69号',
      'place_6_history': 'Khun Anusorn Sombat是社区中的重要人物，其后代将这栋房屋交由社区管理。Arsom Silp学院协助修缮，使其成为一个“学习中心”，供后代和游客参观学习。这被认为是保护尖竹汶河畔社区潮流的起点，使其重新焕发活力。',
"""

en_places = """
      'place_1_name': 'Wat Bot Mueang',
      'place_1_desc': 'An ancient temple of Chanthaburi, notable for its late Ayutthaya bell-shaped stupa.',
      'place_1_long_desc': '''Wat Bot Mueang is a historic local temple in the heart of Chanthaburi, situated on a high hill next to the Chanthaburi River. Presumed to have been built in the late Ayutthaya period, it has been continuously restored and remains a spiritual center for the locals.\\n\\n📜 History & Background\\n• Origin: Built during the Ayutthaya period, as evidenced by the white sandstone boundary markers and the bell-shaped stupa.\\n• Major Restoration: Records indicate the ordination hall was rebuilt in 1787 and received a royal boundary grant in 1792.\\n• Royal Visit: The temple holds historical significance, having been mentioned by King Rama V during his royal tour of Chanthaburi.\\n\\n🏛️ Points of Interest\\n• Principal Buddha & Stupa: Houses the main Buddha image in the ordination hall and an ancient stupa believed to contain Buddha relics.\\n• Ancient Architecture: The original ordination hall, blending Thai and Chinese art, has been well preserved.\\n• Location: Situated on Benchamarachuthit Road, connecting to the Chanthabun Riverside Community.''',
      'place_1_hint': 'Take a photo of the bell-shaped stupa or the glazed tile patterns on the ordination hall gable.',
      'place_1_loc': 'Sukhaphiban Rd, Chanthabun Riverside Community, Mueang, Chanthaburi',
      'place_1_history': 'Believed to have been built during the late Ayutthaya period (around 1852), it is one of the oldest temples in Chanthaburi. Having undergone restorations through many eras, it reveals overlapping historical traces and has long served as both a meditation center and a community hub.',

      'place_2_name': 'Baan Luang Rajamaitri',
      'place_2_desc': 'A 150-year-old golden teak house belonging to the "Father of Eastern Rubber".',
      'place_2_long_desc': '''Baan Luang Rajamaitri (Historic Inn) is a historic residence over 150 years old, created to gather the stories of Luang Rajamaitri, the "Father of Eastern Rubber". It has been restored into a conservation-oriented boutique inn.\\n\\n📜 History & Background\\n• Luang Rajamaitri: A former wealthy merchant who pioneered planting rubber in the eastern region, creating economic prosperity.\\n• Conservation: The community raised funds as a social enterprise to renovate the house into an inn and museum.\\n• International Award: Received the UNESCO Award of Merit in 2015 for cultural heritage conservation.\\n\\n🏛️ Points of Interest\\n• Sino-Portuguese Architecture: The house perfectly blends Western art with Thai golden teak craftsmanship.\\n• Mini Museum: The ground floor displays Luang Rajamaitri\\'s personal belongings and antique account books.\\n• Riverside Atmosphere: The back balcony borders the Chanthaburi River, offering a retro and peaceful vibe.''',
      'place_2_hint': 'Take a photo of the carved wooden balcony by the river or the antique items in the exhibition room.',
      'place_2_loc': '252 Sukhaphiban Rd, Chanthabun Riverside Community, Mueang, Chanthaburi',
      'place_2_history': 'Luang Rajamaitri (Pum Punsri) was a key figure who first introduced rubber seedlings from Malaysia to be test-planted in the eastern region, turning it into a major economic crop. This location was honored with the UNESCO "Award of Merit" in 2015 for cultural heritage conservation in the Asia-Pacific region.',

      'place_3_name': 'Tua Lao Ya Shrine',
      'place_3_desc': 'An ancient Chinese shrine, the center of faith for Thai-Chinese riverside residents.',
      'place_3_long_desc': '''Tua Lao Ya Shrine, also locally known as the Tiger God Shrine, is one of the oldest Southern Chinese style religious sites in the Chanthabun Riverside Community. It is a center of faith for Thai-Chinese people in the area.\\n\\n📜 History & Background\\n• Foundation: Built by a group of Chinese merchants who sailed in to trade and settle over 150 years ago.\\n• Spiritual Center: A spiritual anchor and meeting place for Hokkien and Teochew Chinese.\\n• Major Festivals: The main venue for important traditional festivals like Lunar New Year and the annual ghost festival.\\n\\n🏛️ Points of Interest\\n• Tua Lao Ya Deity: The revered principal deity, prayed to for business success and protection.\\n• Precious Architecture: The wavy tiled roof decorated with twin dragons playing with a pearl, following Chinese beliefs.\\n• Ancient Art: Features delicate gold-leaf wood carvings and traditional mural paintings.''',
      'place_3_hint': 'Take a photo of the dragon patterns on the roof or the ancient Chinese character plaque at the door.',
      'place_3_loc': 'Sukhaphiban Rd, Chanthabun Riverside Community, Mueang, Chanthaburi',
      'place_3_history': 'Built by a group of Chinese merchants who arrived on junk boats to trade and settle by the Chanthaburi River over 150 years ago. This shrine is a testament to past commercial prosperity and serves as the center for hosting important community festivals such as Lunar New Year and the ticket-dispensing festival (The Krachat).',

      'place_4_name': 'Tieng Seng Tueng Vegetarian Hall',
      'place_4_desc': 'The first vegetarian hall in Chanthaburi, the center of the Vegetarian Festival.',
      'place_4_long_desc': '''Tieng Seng Tueng Vegetarian Hall is the first dharma practice site and vegetarian hall in Chanthaburi. Built during the reign of King Rama V, it is notable for its perfectly preserved ancient Chinese art.\\n\\n📜 History & Background\\n• Origin: Built by Chinese immigrants as a place for religious rituals and observing vegetarian precepts.\\n• Long History: Has a history of over 100 years, standing alongside the riverside commercial district.\\n• Vegetarian Festival Center: Has been the heart of Chanthaburi\\'s Vegetarian Festival from the past to the present.\\n\\n🏛️ Points of Interest\\n• Kew Ong Huk Jow: Houses the Nine Emperor Gods and the Goddess Guanyin for worship.\\n• Stucco & Tile Art: Renowned for the art of cutting colored porcelain bowl fragments to decorate into beautiful patterns.\\n• Traditional Architecture: A mixed wood and masonry Southern Chinese architectural style that is rare to see today.''',
      'place_4_hint': 'Take a photo of the colored tile stucco art on the pillars or the Guanyin altar inside.',
      'place_4_loc': 'Sukhaphiban Rd, Chanthabun Riverside Community, Mueang, Chanthaburi',
      'place_4_history': 'This is the oldest vegetarian hall in Chanthaburi province, built during the reign of King Rama V as a spiritual anchor for the Teochew and Hokkien Chinese in the community. It demonstrates the inheritance of strict vegetarian traditions that have lasted for over a century.',

      'place_5_name': 'Cathedral of the Immaculate Conception',
      'place_5_desc': 'The largest and most beautiful Gothic Catholic church in Thailand.',
      'place_5_long_desc': '''The Cathedral of the Immaculate Conception is the largest and most beautiful Gothic-style Catholic church in Thailand. It is a major landmark that has been part of the Chanthabun community for a long time.\\n\\n📜 History & Background\\n• Vietnamese Migration: Began with the settlement of Vietnamese Catholics fleeing religious persecution over 300 years ago.\\n• Construction: The current 5th building was constructed in 1906 by Father Petit, taking 10 years to build.\\n• Historic Event: The spires were dismantled during WWII to avoid being bombing targets, and were reinstalled in 2009.\\n\\n🏛️ Points of Interest\\n• Gem-Adorned Virgin Mary: The statue is decorated with over 200,000 gems weighing over 20,000 carats.\\n• Stained Glass: Beautiful stained glass windows depicting saints, ordered directly from France.\\n• Gothic Architecture: Magnificent Western-style high vaulted ceilings and spires design.''',
      'place_5_hint': 'Take a photo of the stained glass inside the church or the gem-adorned Virgin Mary statue.',
      'place_5_loc': '110 Soi 1 Moo 10, Chanthanimit, Mueang, Chanthaburi (Cross the Niramon Bridge from the riverside community)',
      'place_5_history': 'A group of Vietnamese Catholics seeking religious asylum initiated the first church 300 years ago (1711). The current building is the 5th, built in 1906 (King Rama V era) taking 10 years. The spires were removed during WWII so as not to be an air raid target, and were only reinstalled in 2009.',

      'place_6_name': 'Chanthabun Riverside Community Learning Center (No. 69)',
      'place_6_desc': 'A living museum collecting the memories of Chanthabun residents.',
      'place_6_long_desc': '''The Chanthabun Riverside Community Learning Center (House No. 69) was formerly the residence of Khun Anusorn Sombat. Today, it serves as a "living museum" telling the memories and stories of this old commercial district.\\n\\n📜 History & Background\\n• Khun Anusorn Sombat\\'s House: A former wealthy merchant who played an important role in the community; the house reflects past prosperity.\\n• Dedicated to the Community: His heirs donated this house to be a community asset to serve as a learning source.\\n• Catalyst for Conservation: It was a crucial spark that initiated the conservation and revitalization of the riverside community.\\n\\n🏛️ Points of Interest\\n• History Exhibition: Collects photos of important events, antique maps, and everyday items from the past.\\n• Community Diorama: Displays a 3D model of the riverside district and various architectural buildings.\\n• Mixed Architecture: The house stands out with its folding doors and carved wooden vents, blending Thai and French art.''',
      'place_6_hint': 'Take a photo of the community diorama or the carved wooden vents above the doors.',
      'place_6_loc': '69 Sukhaphiban Rd, Chanthabun Riverside Community, Mueang, Chanthaburi',
      'place_6_history': 'Khun Anusorn Sombat was a prominent figure in the community. Later, his heirs handed the house over to the community to manage, and the Arsom Silp Institute helped restore it into a "Learning Center" for later generations and tourists to study. This is considered the starting point of the conservation movement for the Chanthabun riverside community, bringing it back to life.',
"""

content = content.replace("      'take_photo': 'ถ่ายภาพ ณ สถานที่นี้',", "      'take_photo': 'ถ่ายภาพ ณ สถานที่นี้',\n" + th_places)
content = content.replace("      'take_photo': '在此拍照',", "      'take_photo': '在此拍照',\n" + zh_places)
content = content.replace("      'take_photo': 'Take Photo Here',", "      'take_photo': 'Take Photo Here',\n" + en_places)

with open(r'e:\rimnam_app\lib\core\localization\app_translations.dart', 'w', encoding='utf-8') as f:
    f.write(content)
