// ***************************************************************************
//  Copyright (c) <2024> <Bruno Seleguim>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
// *************************************************************************** }

unit MVCFramework.Middleware.Paginate;

{$I dmvcframework.inc}

interface

uses
  MVCFramework,
  System.Classes;

type

  TMVCPaginateMiddleware = class(TInterfacedObject, IMVCMiddleware)
  public
    procedure OnBeforeRouting(AContext: TWebContext; var AHandled: Boolean);
    procedure OnBeforeControllerAction(AContext: TWebContext; const AControllerQualifiedClassName: string;
      const AActionName: string; var AHandled: Boolean);
    procedure OnAfterControllerAction(AContext: TWebContext; const AControllerQualifiedClassName: string;
      const AActionName: string; const AHandled: Boolean);
    procedure OnAfterRouting(AContext: TWebContext; const AHandled: Boolean);
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  System.JSON;

{ TMVCPaginateMiddleware }

procedure TMVCPaginateMiddleware.OnAfterControllerAction(AContext: TWebContext;
	const AControllerQualifiedClassName: string;
    const AActionName: string;
	const AHandled: Boolean);
begin
  // do nothing
end;

procedure TMVCPaginateMiddleware.OnAfterRouting(AContext: TWebContext; const AHandled: Boolean);
var
  LLimit, LPage: string;
  LPages: Double;
  LJsonValue: TJSONValue;
  LResultsJsonArray: TJSONArray;
  LJsonObjectResponse: TJSONObject;
begin
  if (AContext.Response.RawWebResponse.ContentStream = nil) then
    Exit;

  if not AContext.Response.ContentType.Contains('application/json') then
    Exit;

  if (LowerCase(AContext.Request.Headers['X-Paginate']) = 'true') then
  begin
    if not AContext.Request.QueryStringParamExists('limit') then
      LLimit := '25'
    else
      LLimit := AContext.Request.QueryStringParam('limit');

    if not AContext.Request.QueryStringParamExists('page') then
      LPage := '1'
    else
      LPage := AContext.Request.QueryStringParam('page');

    LJsonValue := TJSONValue.ParseJSONValue(TEncoding.UTF8.GetBytes((AContext.Response.RawWebResponse.ContentStream as TStringStream).DataString), 0) as TJSONValue;
    if (Assigned(LJsonValue)) and (LJsonValue is TJSONArray) then
    begin
      LPages := Ceil((LJsonValue as TJSONArray).Count / LLimit.ToInteger);

      LResultsJsonArray := TJsonArray.Create;
      for var I := (LLimit.ToInteger * (LPage.ToInteger - 1)) to ((LLimit.ToInteger * LPage.ToInteger)) - 1 do
      begin
        if I < (LJsonValue as TJSONArray).Count then
          LResultsJsonArray.AddElement((LJsonValue as TJSONArray).Items[I].Clone as TJSONValue);
      end;

      LJsonObjectResponse := TJsonObject.Create;
      LJsonObjectResponse.AddPair('results', LResultsJsonArray);
      LJsonObjectResponse.AddPair('total', TJSONNumber.Create((LJsonValue as TJSONArray).Count));
      LJsonObjectResponse.AddPair('limit', TJSONNumber.Create(LLimit.ToInteger));
      LJsonObjectResponse.AddPair('page',  TJSONNumber.Create(LPage.ToInteger));
      LJsonObjectResponse.AddPair('pages', TJSONNumber.Create(LPages));
      AContext.Response.Content := LJsonObjectResponse.ToString;
    end;
  end;
end;

procedure TMVCPaginateMiddleware.OnBeforeControllerAction(AContext: TWebContext; const AControllerQualifiedClassName,
  AActionName: string; var AHandled: Boolean);
begin
  // do nothing
end;

procedure TMVCPaginateMiddleware.OnBeforeRouting(AContext: TWebContext; var AHandled: Boolean);
begin
  // do nothing
end;

end.
