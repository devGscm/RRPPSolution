/*
 * Copyright (C) 2015 - 2017, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material

class AppToolbarController: ToolbarController
{
    fileprivate var menuButton: IconButton!
    fileprivate var switchControl: Switch!
    fileprivate var moreButton: IconButton!
	fileprivate var ibHome: IconButton!
	
	lazy var clsRootController: RootViewController = {
		return UIStoryboard.viewController(identifier: "RootViewController") as! RootViewController
	}()
	
    override func prepare()
	{
        super.prepare()
        prepareMenuButton()
      // yomile, prepareSwitch()
		//prepareMoreButton()
		prepareHomeButton()
        prepareStatusBar()
        prepareToolbar()
    }
}

extension AppToolbarController
{
    fileprivate func prepareMenuButton()
	{
        menuButton = IconButton(image: Icon.cm.menu)
		menuButton.tintColor = Color.white
		menuButton.pulseColor = .white
		//starButton = IconButton(image: Icon.cm.star, tintColor: .white)
		
        menuButton.addTarget(self, action: #selector(handleMenuButton), for: .touchUpInside)
    }
    
    fileprivate func prepareSwitch()
	{
        switchControl = Switch(state: .off, style: .light, size: .small)
    }
    
    fileprivate func prepareMoreButton()
	{
        //moreButton = IconButton(image: Icon.cm.moreVertical)
		moreButton = IconButton(image: Icon.home)
		moreButton.tintColor = Color.white
        moreButton.addTarget(self, action: #selector(handleMoreButton), for: .touchUpInside)
    }
	
	
	fileprivate func prepareHomeButton()
	{
		//ibHome = IconButton(image: Icon.cm.moreVertical)
		ibHome = IconButton(image: Icon.home)
		ibHome.tintColor = Color.white
		ibHome.addTarget(self, action: #selector(handleHomeButton), for: .touchUpInside)
	}

    
    fileprivate func prepareStatusBar()
	{
        statusBarStyle = .lightContent
        // Access the statusBar.
		//statusBar.backgroundColor = Color.green.base
		statusBar.backgroundColor = Color.blue.darken3
		
		
		
		
		
		//print("@@@@@@HEX:\(Color.blue.darken3.toHexString) ")
		
		//UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1)
		//statusBar.backgroundColor = Color.blue.base
    }
    
    fileprivate func prepareToolbar()
	{
		toolbar.leftViews = [menuButton]
		// yomile toolbar.rightViews = [switchControl, moreButton]
		toolbar.rightViews = [ ibHome]
		toolbar.backgroundColor = Color.blue.base
		toolbar.titleLabel.textColor = Color.white
		//toolbar.detailLabel.font = UIFont.systemFont(ofSize: 18)
    }
}

extension UIColor {
	var toHexString: String {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		return String(
			format: "%02X%02X%02X",
			Int(r * 0xff),
			Int(g * 0xff),
			Int(b * 0xff)
		)
	}
}

extension AppToolbarController {
    @objc
    fileprivate func handleMenuButton() {
        navigationDrawerController?.toggleLeftView()
    }
    
    @objc
    fileprivate func handleMoreButton() {
        navigationDrawerController?.toggleRightView()
    }
	
	@objc
	fileprivate func handleHomeButton()
	{
		// 옵져버 전달
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "doMoveHome"), object: nil)
	}
}
