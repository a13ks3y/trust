import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-login-page',
  templateUrl: './login-page.component.html',
  styleUrls: ['./login-page.component.less']
})
export class LoginPageComponent implements OnInit {
  loginValid = false;
  username = "";
  password = "";

  constructor() { }
  ngOnInit(): void {
  }

  onSubmit() {
    // @todo: try to login to GitHub using OAuth
  }

}
