//
//  TagSupply.swift
//  RRPPClient
//
//  Created by Moramcnt on 2017. 12. 15..
//  Copyright © 2017년 Logisall. All rights reserved.
//

import UIKit
import Material

class TagSupply: BaseRfidViewController, UITableViewDataSource, UITableViewDelegate, DataProtocol, ReaderResponseDelegate
{
	@IBOutlet weak var lblReaderName: UILabel!
	@IBOutlet weak var btnRfidReader: UIButton!
	@IBOutlet weak var btnIssueOrderId: UIButton!
	@IBOutlet weak var lblOrderCustName: UILabel!
	@IBOutlet weak var lblOrderCount: UILabel!
	
	@IBOutlet weak var btnWorkDate: UITextField!
	@IBOutlet weak var tvTagSupply: UITableView!

	var strIssueOrderId: String = ""
	var strTagCustId : String = ""		/** 태그 생산회사 */
	var intOrderWorkCnt: Int = 0
	var intOrderReqCnt: Int = 0
	var strAssetEpc: String?
	var intCurOrderWorkCnt: Int = 0
	
	
	var arrAssetRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	var arrTagRows : Array<RfidUtil.TagInfo> = Array<RfidUtil.TagInfo>()
	
	var clsIndicator : ProgressIndicator?
	var clsDataClient : DataClient!
	
	//TODO : 캘린더관련 컨트롤 재 수정
	var dpPicker: UIDatePicker!
	var tfCurControl : UITextField!
	
	override func viewWillAppear(_ animated: Bool)
	{
		print("=========================================")
		print("*TagSupply.viewWillAppear()")
		print("=========================================")
		super.viewWillAppear(animated)
		prepareToolbar()
		
		//RFID를 처리할 델리게이트 지정
		self.initRfid(self as ReaderResponseDelegate )
		
		initViewControl()
        
        // 2018 0807 bhkim, 화면 꺼짐 방지 설정 = ON
        UIApplication.shared.isIdleTimerDisabled = true
	}
	
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
	}
	
	override func viewDidDisappear(_ animated: Bool)
	{
		print("=========================================")
		print("*TagSupply.viewDidDisappear()")
		print("=========================================")
		arrAssetRows.removeAll()
		arrTagRows.removeAll()
		clsIndicator = nil
		clsDataClient = nil
        
        // 2018 0807 bhkim, 화면 꺼짐 방지 설정 = OFF
        //UIApplication.shared.isIdleTimerDisabled = false
		
		super.destoryRfid()
		super.viewDidDisappear(animated)
	}
	
	// View관련 컨트롤을 초기화한다.
	func initViewControl()
	{
		clsIndicator = ProgressIndicator(view: self.view, backgroundColor: UIColor.gray,
										 indicatorColor: ProgressIndicator.INDICATOR_COLOR_WHITE, message: "로딩중입니다.")
		lblReaderName.text = AppContext.sharedManager.getUserInfo().getReaderDevName()
		
		lblOrderCustName.text = ""
		lblOrderCount.text = ""
		
		dpPicker = UIDatePicker()
		let dtCurDate = Date()
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = "yyyy-MM-dd"
		btnWorkDate.text = dfFormat.string(from: dtCurDate)
		
		// 테이블뷰 셀표시 지우기
		tvTagSupply.tableFooterView = UIView(frame: CGRect.zero)
	}
	
	
	// Segue로 파라미터 넘기면 반드시 prepare를 타기 때문에 여기서 DataProtocol을 세팅하는걸로 함
	override func prepare(for segue: UIStoryboardSegue, sender: Any?)
	{
		if(segue.identifier == "segTagOrderSearch")
		{
			if let clsDialog = segue.destination as? TagOrderSearch
			{
				clsDialog.ptcDataHandler = self
			}
		}
		else if(segue.identifier == "segTagDetailList")
		{
			if let clsDialog = segue.destination as? TagDetailList
			{
				if let btnDetail = sender as? UIButton
				{
					let clsTagInfo = arrAssetRows[btnDetail.tag]
					
					// 해당 자산코드만 필터링하여 배열을 재생성하여 전달
					let arrData = arrTagRows.filter({ (clsData) -> Bool in
						if(clsData.getAssetEpc() == clsTagInfo.getAssetEpc())
						{
							return true
						}
						return false
					})
					clsDialog.loadData(  arcTagInfo : arrData)
				}
			}
		}
	}
	
	// 팝업 다이얼로그로 부터 데이터 수신
	func recvData( returnData : ReturnData)
	{
		if(returnData.returnType == "tagOrderSearch")
		{
			if(returnData.returnRawData != nil)
			{
				clearUserInterfaceData()
				
				let clsDataRow = returnData.returnRawData as! DataRow
				strIssueOrderId	= clsDataRow.getString(name: "issueOrderId") ?? ""
				intOrderWorkCnt	= clsDataRow.getInt(name: "orderWorkCnt") ?? 0
				intOrderReqCnt	= clsDataRow.getInt(name: "orderReqCnt") ?? 0
				strAssetEpc = clsDataRow.getString(name: "assetEpc")
				strTagCustId = clsDataRow.getString(name: "tagCustId") ?? ""
				intCurOrderWorkCnt = intOrderWorkCnt
				
				print("@@@@@@@@strIssueOrderId=\(strIssueOrderId)")
				print("@@@@@@@@intOrderWorkCnt=\(intOrderWorkCnt)")
				
				DispatchQueue.main.async {
					self.btnIssueOrderId.setTitle(self.strIssueOrderId, for: .normal)
					self.lblOrderCustName.text = clsDataRow.getString(name: "orderCustName")
					self.lblOrderCount.text = "\(self.intOrderWorkCnt)/\(self.intOrderReqCnt)"
				}
				
				// 새로운 발주번호가 들어면 기존 데이터를 삭제한다.
				clearTagData()
			}
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	////   리더기 관련 이벤트및 처리 시작
	//////////////////////////////////////////////////////////////////////////////////////////
	// 리더기 연결 클릭이벤트
	@IBAction func onRfidReaderClicked(_ sender: UIButton)
	{
		if(sender.isSelected == false)
		{
			showSnackbar(message: NSLocalizedString("rfid_connecting_reader", comment: "RFID 리더기에 연결하는 중 입니다."))
			//print(" 리더기 연결")
			super.readerConnect()
		}
		else
		{
			super.readerDisConnect()
		}
	}
	
	//리더기에서 읽어드린 태그에 대한 이벤트 발생처리
	func didReadTagid(_ tagid: String)
	{
		let clsTagInfo = RfidUtil.parse(strData: tagid)
		getRfidData(clsTagInfo: clsTagInfo)
	}
	
	//리더기 연결성공
	func didReaderConnected()
	{
		showSnackbar(message: NSLocalizedString("rfid_connected_reader", comment: "RFID 리더기에 연결되었습니다."))
		changeBtnRfidReader(true)
	}
	
	//리더기 연결종로
	func didReaderDisConnected()
	{
		showSnackbar(message: NSLocalizedString("rfid_connection_terminated", comment: "연결이 종료되었습니다."))
		changeBtnRfidReader(false)
	}
	
	//리더기 연결 타임오바
	func didRederConnectTimeOver()
	{
		showSnackbar(message: NSLocalizedString("rfid_not_connect_reader", comment: "RFID 리더기에 연결할수 없습니다."))
		changeBtnRfidReader(false)
	}
	
	//리더기 연결 여부에 따른 버튼에대한 상태값 변경
	func changeBtnRfidReader(_ isConnected : Bool)
	{
		if(isConnected )
		{
			self.btnRfidReader.isSelected = true
			self.btnRfidReader.backgroundColor = Color.orange.base
			self.btnRfidReader.tintColor = Color.orange.base
			self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_close", comment: "종료"), for: .normal)
		}
		else
		{
			self.btnRfidReader.isSelected = false
			self.btnRfidReader.backgroundColor = Color.blue.base
			self.btnRfidReader.tintColor = Color.white
			self.btnRfidReader.setTitle(NSLocalizedString("rfid_reader_connect", comment: "연결"), for: .normal)
		}
	}
	
	//////////////////////////////////////////////////////////////////////////////////////////
	////   리더기 관련 이벤트및 처리 종료
	//////////////////////////////////////////////////////////////////////////////////////////
	
	// 주문선택
	@IBAction func onMakeOrderIdClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segTagOrderSearch", sender: self)
	}
	
	// 데이터를 clear한다.
	func clearTagData()
	{
		arrTagRows.removeAll()
		arrAssetRows.removeAll()
		
		tvTagSupply?.reloadData()
		
		self.intCurOrderWorkCnt = self.intOrderWorkCnt
		if(lblOrderCustName.text?.isEmpty == false)
		{
			lblOrderCount?.text = "\(self.intCurOrderWorkCnt)/\(self.intOrderReqCnt)"
		}
		super.clearInventory()
	}
	
	func getRfidData( clsTagInfo : RfidUtil.TagInfo)
	{
		let strCurReadTime = DateUtil.getDate(dateFormat: "yyyyMMddHHmmss")
		let strSerialNo = clsTagInfo.getSerialNo()
		let strAssetEpc = "\(clsTagInfo.getCorpEpc())\(clsTagInfo.getAssetEpc())"	// 회사EPC코드 + 자산EPC코드
		
		//------------------------------------------------
        clsTagInfo.setAssetEpc(strAssetEpc)
		if(clsTagInfo.getAssetEpc().isEmpty == false)
		{
			let strAssetName = super.getAssetName(assetEpc: strAssetEpc)
            clsTagInfo.setAssetName(strAssetName)
			print("@@@@@@@@ AssetName2:\(clsTagInfo.getAssetName() )")
		}
        clsTagInfo.setNewTag(true)
        clsTagInfo.setReadCount(1)
        clsTagInfo.setReadTime(strCurReadTime)
		//------------------------------------------------
		
		var boolValidAsset = false
		var boolFindSerialNoOverlap = false
		var boolFindAssetTypeOverlap = false
		for clsAssetInfo in super.getAssetList()
		{
			print("@@@@@clsAssetInfo.assetEpc:\(clsAssetInfo.assetEpc)")
			if(clsAssetInfo.assetEpc == strAssetEpc)
			{
				// 자산코드에 등록되어 있는 경우
				print(" 동일한 자산코드 존재")
				boolValidAsset = true
				break;
			}
		}
		print(" 자산코드:\(strAssetEpc), ExistAssetInfo:\(boolValidAsset)")
		if(boolValidAsset == true)
		{
			// Detail 다이얼로그 전달용 태그 리스트
			for clsTagInfo in arrTagRows
			{
				// 같은 시리얼번호가 있는지 체크
				if(clsTagInfo.getSerialNo() == strSerialNo)
				{
					print(" 동일한 시리얼번호 존재")
					boolFindSerialNoOverlap = true
					break;
				}
			}
			
			// 시리얼번호가 중복이 안되어 있다면
			if(boolFindSerialNoOverlap == false)
			{
				// 상세보기용 배열에 추가
				arrTagRows.append(clsTagInfo)
				
				for clsTagInfo in arrAssetRows
				{
					// 같은 자산유형이 있다면 자산유형별로 조회수 증가
					if(clsTagInfo.getAssetEpc() == strAssetEpc)
					{
						boolFindAssetTypeOverlap = true
						let intCurReadCount = clsTagInfo.getReadCount()
                        clsTagInfo.setReadCount((intCurReadCount + 1))
						break;
					}
				}
				
				// 마스터용 배열에 추가
				if(boolFindAssetTypeOverlap == false)
				{
					arrAssetRows.append(clsTagInfo)
				}
				
				let intCurDataSize = arrTagRows.count
				
				// 발주번호가 있는 경무만 "처리수량/발주수량"을 처리한다.
				
				print("@@@@@@strIssueOrderId:\(strIssueOrderId)")
				
				if(strIssueOrderId.isEmpty == false)
				{
					intCurOrderWorkCnt = intOrderWorkCnt + intCurDataSize
					lblOrderCount.text = "\(intCurOrderWorkCnt)/\(intOrderReqCnt)"
				}
			}
		}
		DispatchQueue.main.async { self.tvTagSupply?.reloadData() }
	}
	
	func sendData(issueOrderId: String, workData: String, workerName: String, remark: String)
	{
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		print("issueOrderId:\(issueOrderId)")
		print("workData:\(workData)")
		print("workerName:\(workerName)")
		print("remark:\(remark)")
		print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
		
		clsIndicator?.show(message: NSLocalizedString("common_progressbar_sending", comment: "전송중 입니다."))
		
		//		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
		//			self.clsIndicator?.hide()
		//		}
		
		clsDataClient = DataClient(container:self, url: Constants.WEB_SVC_URL)
		clsDataClient.UserInfo = AppContext.sharedManager.getUserInfo().getEncryptId()
		clsDataClient.ExecuteUrl = "supplyService:executeSupplyData"
		clsDataClient.removeServiceParam()
		
		clsDataClient.addServiceParam(paramName: "corpId", value: AppContext.sharedManager.getUserInfo().getCorpId())
		clsDataClient.addServiceParam(paramName: "userId", value: AppContext.sharedManager.getUserInfo().getUserId())
		clsDataClient.addServiceParam(paramName: "unitId", value: AppContext.sharedManager.getUserInfo().getUnitId())
		clsDataClient.addServiceParam(paramName: "branchId", value: AppContext.sharedManager.getUserInfo().getBranchId())
		clsDataClient.addServiceParam(paramName: "branchCustId", value: AppContext.sharedManager.getUserInfo().getBranchCustId())
		clsDataClient.addServiceParam(paramName: "tagCustId", value: strTagCustId)
		clsDataClient.addServiceParam(paramName: "issueOrderId", value: issueOrderId)
		clsDataClient.addServiceParam(paramName: "workDate", value: workData)
		clsDataClient.addServiceParam(paramName: "workerName", value: workerName)
		clsDataClient.addServiceParam(paramName: "workRemark", value: remark)
		
		let clsDataTable : DataTable = DataTable()
		clsDataTable.Id = "TAG_MOUNT"
		clsDataTable.addDataColumn(dataColumn: DataColumn(id: "epcCode", type: "String", size: "0", keyColumn: false, updateColumn: true, autoIncrement: false, canXlsExport: false, title: ""))
		
		for clsInfo in self.arrTagRows
		{
			let clsDataRow : DataRow = DataRow()
			clsDataRow.State = DataRow.DATA_ROW_STATE_ADDED
			clsDataRow.addRow(name:"epcCode", value: clsInfo.getEpcCode())
			clsDataTable.addDataRow(dataRow: clsDataRow)
		}
		clsDataClient.executeData(dataTable: clsDataTable, dataCompletionHandler: { (data, error) in
			self.clsIndicator?.hide()
			if let error = error {
				// 에러처리
				super.showSnackbar(message: error.localizedDescription)
				print(error)
				return
			}
			guard let clsResultDataTable = data else {
				print("에러 데이터가 없음")
				return
			}
			
			print("####결과값 처리")
			let clsResultDataRows = clsResultDataTable.getDataRows()
			if(clsResultDataRows.count > 0)
			{
				let clsDataRow = clsResultDataRows[0]
				let strResultCode = clsDataRow.getString(name: "resultCode")
				
				print(" -strResultCode:\(strResultCode!)")
				if(Constants.PROC_RESULT_SUCCESS == strResultCode)
				{
					//비동기 처리 결과에대한  UI에한 처리는 반드시 쓰레드로 처리되어야 한다.
					DispatchQueue.main.async {
						self.clearTagData()
						self.clearUserInterfaceData()
						let strMsg = NSLocalizedString("common_success_sent", comment: "성공적으로 전송하였습니다.")
						self.showSnackbar(message: strMsg)
					}
				}
				else
				{
					let strMsg = super.getProcMsgName(userLang: AppContext.sharedManager.getUserInfo().getUserLang(), commCode: strResultCode!)
					self.showSnackbar(message: strMsg)
				}
			}
		})
	}
	
	func clearUserInterfaceData()
	{
		intOrderWorkCnt	= 0
		intCurOrderWorkCnt = 0
		intOrderReqCnt	= 0
		
		strIssueOrderId	= ""
		strAssetEpc = ""
		strTagCustId = ""
	
		self.btnIssueOrderId.setTitle(NSLocalizedString("make_order_id_selection", comment: "주문선택"), for: .normal)
		self.lblOrderCustName.text = ""
		self.lblOrderCount.text = ""
		
		let dtCurDate = Date()
		let dfFormat = DateFormatter()
		dfFormat.dateFormat = "yyyy-MM-dd"
		self.btnWorkDate.text = dfFormat.string(from: dtCurDate)		
	}
	
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return self.arrAssetRows.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		//let cell : UITableViewCell = UITableViewCell(style: <#T##UITableViewCellStyle#>, reuseIdentifier: <#T##String?#>)
		let objCell:TagSupplyCell = tableView.dequeueReusableCell(withIdentifier: "tvcTagSupply", for: indexPath) as! TagSupplyCell
		let clsTagInfo = arrAssetRows[indexPath.row]
		
		
		objCell.lblAssetName.text = clsTagInfo.getAssetName()
		objCell.lblReadCount.text = "\(clsTagInfo.getReadCount())"
		
		objCell.btnDetail.titleLabel?.font = UIFont.fontAwesome(ofSize: 14)
		objCell.btnDetail.setTitle(String.fontAwesomeIcon(name: .listAlt), for: .normal)
		objCell.btnDetail.tag = indexPath.row
		objCell.btnDetail.addTarget(self, action: #selector(onTagListClicked(_:)), for: .touchUpInside)
		return objCell
	}
	
	//납품일설정
	@IBAction func onWorkDateClicked(_ sender: Any) {
		createDatePicker(tfDateControl: btnWorkDate)
	}
	
	func createDatePicker(tfDateControl : UITextField)
	{
		print("@@@@@@createDatePicker")
		tfCurControl = tfDateControl
		
		dpPicker.locale = Locale(identifier: "ko_KR")
		dpPicker.datePickerMode = .date
		let dfFormatter = DateFormatter()
		dfFormatter.dateFormat = "yyyy-MM-dd"
		if let selDate = dfFormatter.date(from: tfDateControl.text ?? "")
		{
			dpPicker.date = selDate
		}
		
		let toolbar = UIToolbar()
		toolbar.sizeToFit()
		
		let bbiDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDoneButtonPressed))
		toolbar.setItems([bbiDoneButton], animated: false)
		tfDateControl.inputAccessoryView = toolbar
		tfDateControl.inputView = dpPicker
	}
	
	@objc func onDoneButtonPressed(_ sender : Any)
	{
		let dfFormatter = DateFormatter()
		dfFormatter.dateFormat = "yyyy-MM-dd"
		tfCurControl.text = dfFormatter.string(from: dpPicker.date)
		self.view.endEditing(true)
	}
	
	// RFID 태그 목록 보기
	@objc func onTagListClicked(_ sender: UIButton)
	{
		self.performSegue(withIdentifier: "segTagDetailList", sender: self)
	}
	
	// 초기화
	@IBAction func onClearAllClicked(_ sender: UIButton)
	{
		Dialog.show(container: self, viewController: nil,
					title: NSLocalizedString("common_delete", comment: "삭제"),
					message: NSLocalizedString("common_confirm_delete", comment: "전체 데이터를 삭제하시겠습니까?"),
					okTitle: NSLocalizedString("common_confirm", comment: "확인"),
					okHandler: { (_) in
						self.clearTagData()
						super.showSnackbar(message: NSLocalizedString("common_success_delete", comment: "성공적으로 삭제되었습니다."))
		},
					cancelTitle: NSLocalizedString("common_cancel", comment: "취소"), cancelHandler: nil)
	}
	
	// 전송
	@IBAction func onSendClicked(_ sender: UIButton)
	{
		if(AppContext.sharedManager.getUserInfo().getUnitId().isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_reader_no_device_id", comment: "리더기의 장치ID가 없습니다.웹화면의 리더기정보관리에서 모바일전화번호를  입력하여주십시오."))
			return
		}
		if(arrAssetRows.count == 0)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("common_no_data_send", comment: "전송할 데이터가 없습니다."))
			return
		}
		
		let strIssueOrderId = btnIssueOrderId.titleLabel?.text
		if(strIssueOrderId?.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_enter_your_order_no", comment: "발주번호를 입력하여 주십시오."))
			return
		}
		
		var strWorkDate = btnWorkDate?.text ?? ""
		if(strWorkDate.isEmpty == true)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("rfid_enter_your_delivery_date", comment: "납품일자를 입력하주 주십시요"))
			return
		}
		
		for clsInfo in self.arrTagRows
		{
			if(self.strAssetEpc != clsInfo.getAssetEpc())
			{
				Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("stock_can_not_processed_because_different_pallet", comment: "품목이 다른 파렛트가 있어 처리 할 수 없습니다."))
				return
			}
		}
		
		let intTagCount = 0
		let intCurWorkCount = self.intOrderWorkCnt + intTagCount // 기제작수량과 현재 인식한 태그 수량
		// 발주수량보다 크면
		if(intCurWorkCount > self.intOrderReqCnt)
		{
			Dialog.show(container: self, title: NSLocalizedString("common_error", comment: "에러"), message: NSLocalizedString("make_cannot_handle_amount_greater_qty", comment: "인식수량이 발주 수량보다 많을수는 없습니다."))
			return
		}
		
		
		let acDialog = UIAlertController(title: NSLocalizedString("common_confirm", comment: "확인"), message: nil, preferredStyle: .alert)
		acDialog.addTextField() {
			$0.placeholder = NSLocalizedString("make_remark", comment: "확인")
		}
		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_cancel", comment: "취소"), style: .default) { (_) in
			acDialog.textFields?[0].text = ""
		})
		acDialog.addAction(UIAlertAction(title: NSLocalizedString("common_confirm", comment: "확인"), style: .default) { (_) in
			let strIssueOrderId = self.btnIssueOrderId?.titleLabel?.text
			let dtCurDate = Date()
			let dfFormat = DateFormatter()
			dfFormat.dateFormat = "hhmmss"
			let strCurTime = dfFormat.string(from: dtCurDate)
			strWorkDate = StrUtil.replace(sourceText: strWorkDate,  findText: "-", replaceText: "") + strCurTime
			
			let strWorkerName = AppContext.sharedManager.getUserInfo().getUserName()
			let strRemark = acDialog.textFields?[0].text
			self.sendData(issueOrderId: strIssueOrderId!, workData: strWorkDate, workerName: strWorkerName, remark: strRemark!)
		})
		self.present(acDialog, animated: true, completion: nil)
		
	}
}


extension TagSupply
{
	fileprivate func prepareToolbar()
	{
		guard let tc = toolbarController else {
			return
		}
		//tc.toolbar.title = NSLocalizedString("app_title", comment: "RRPP TRA")
		tc.toolbar.title = NSLocalizedString("title_tag_supply", comment: "납품등록(RFID)")
	}
}

